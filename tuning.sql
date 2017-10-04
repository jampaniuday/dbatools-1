set echo off
set feedback off
column timecol new_value timestamp
spool tuning_out.log
set lines 200
set term off
set pagesize 45
Set Linesize 200
Set Pagesize 45
Set Desc Linenum On
Set Arraysize 1
Set Long 2000
Set Serveroutput On size 800000 ;
set trim on
set trims on
alter session set nls_date_format = 'DD-MM-YYYY HH24:MI:SS';
alter session set timed_statistics = true;
set feedback on
select to_char(sysdate) time from dual;

set numwidth 5
column host_name format a20 tru
select inst_id, instance_name, host_name, version, status, startup_time
from gv$instance
order by inst_id;


Ttitle  ' [ CANDIDATE FOR KEEP POOL ]'  skip 1
-- objects that are small and experience a d
-- is proportional amount of I/O activity
ttitle  -
        'Adjust db_keep_cache_size tocache all of the segments that are assigned to the pool.' - skip 1 -
        'After choosing tables and indexes you can keep in pool using below commands' - skip 1 - 
        'ALTER TABLE Table_name STORAGE (BUFFER_POOL KEEP);'-skip 1  -
        'ALTER INDEX Index_name STORAGE (BUFFER_POOL KEEP);'- skip 1 -
        'We look cache for:' - skip 1   -
        '	1- Tables y indexes where the tabl e is small (<100 blocks) and Table frequent full-table scans.'  - skip 1 -
        '	2- Objects that consume more than 10% of the size of their data buffer.' - skip 1 -
        skip 2


Ttitle  ' [ Access is High+Small tables] '  skip 1
SELECT
   p.owner,
   p.NAME,
t.CACHE,
 t.BUFFER_POOL,
s.blocks blocks,
   SUM(sa.executions) FTS_NO
FROM
   dba_tables t,
   dba_segments s,
  v$sqlarea sa,
  (SELECT DISTINCT
    sql_id stid,
     object_owner owner,
     object_name NAME
   FROM
   dba_hist_sql_plan
   WHERE
   object_owner NOT LIKE '%SYS%' AND
      operation = 'TABLE ACCESS'
      AND
      options = 'FULL') p
WHERE
 sa.sql_id = p.stid
 AND
   t.owner = s.owner
   AND
   t.table_name = s.segment_name
   AND
   t.table_name = p.NAME
   AND
   t.owner = p.owner
GROUP BY
   p.owner, p.NAME, t.CACHE, t.BUFFER_POOL, s.blocks
   HAVING
   SUM(sa.executions) > 10
   AND s.blocks < 100
ORDER BY
  SUM(sa.executions) DESC;
  
  
Rem Find the frequency for FTS 
Ttitle  ' [ Find the frequency for FTS ] '  skip 1
col object_name form a20 wrapped heading MYNAME

SELECT 
   b.owner,object_type  mytype,
   object_name,
   blocks,
   COUNT(1) buffers,
   AVG(tch) avg_touches
FROM
   sys. x$bh    a,
   dba_objects b,
   dba_segments s
WHERE
   a.obj = b.object_id
AND
   b.object_name = s.segment_name
AND
   b.owner NOT IN ('SYS','SYSTEM','SYSMAN')
GROUP BY
   object_name,
   object_type,
   blocks,
   obj,b.owner
HAVING
   AVG(tch) > 5
AND
   COUNT(1) > 20 
ORDER BY 6 ASC
/


Ttitle  ' [ Objects that consume more than 10% of the size of their data buffer ] '  skip 1
Rem Objects that consume more than 10% of the size of their data buffer

SELECT
   s.segment_type,t1.owner,s.segment_name, (SUM(num_blocks)/GREATEST(SUM(blocks), .001))*100 AS "segment_%_in_sga"
FROM
     (
SELECT
   o.owner          owner,
   o.object_name    object_name,
   o.subobject_name subobject_name,
   o.object_type    object_type,
   COUNT(DISTINCT FILE# || BLOCK#)         num_blocks
FROM
   dba_objects  o,
   v$bh         bh
WHERE
   o.data_object_id  = bh.objd
AND
   o.owner NOT IN ('SYS','SYSTEM')
AND
   bh.status != 'free'
GROUP BY
   o.owner,
   o.object_name,
   o.subobject_name,
   o.object_type
ORDER BY
   COUNT(DISTINCT FILE# || BLOCK#) DESC
)t1,
   dba_segments s
WHERE
   s.segment_name = t1.object_name
AND
   s.owner = t1.owner
AND
   s.segment_type = t1.object_type
AND
   NVL(s.partition_name,'-') = NVL(t1.subobject_name,'-')
AND
   BUFFER_POOL <> 'KEEP'
AND
   object_type IN ('TABLE','INDEX')
GROUP BY
   s.segment_type,
   t1.owner,
   s.segment_name
HAVING
   (SUM(num_blocks)/GREATEST(SUM(blocks), .001))*100 > 10
   ORDER BY 4 DESC
;


Ttitle  ' [ % of segment present in sga ] '  skip 1

SELECT
s.segment_type,t1.owner,s.segment_name,S.BYTES/1024/1024/1024 total_size ,num_blocks*32/1024/1024 size_occup_In_SGA,
(num_blocks*32/1024/1024)*100/(S.BYTES/1024/1024/1024) SIZE_%_IN_SGA
FROM
  ( SELECT
   o.owner          owner,
   o.object_name    object_name,
   o.subobject_name subobject_name,
   o.object_type    object_type,
   COUNT(*)         num_blocks
FROM
   dba_objects  o,
   v$bh         bh
WHERE
   o.data_object_id  = bh.objd
AND
   o.owner NOT IN ('SYS','SYSTEM','SYSMAN')
AND
   bh.status != 'free'
GROUP BY
   o.owner,
   o.object_name,
   o.subobject_name,
   o.object_type
) t1,
   dba_segments s
WHERE
   s.segment_name = t1.object_name
AND
   s.owner = t1.owner
AND
   s.segment_type = t1.object_type
AND
   NVL(s.partition_name,'-') = NVL(t1.subobject_name,'-')
AND
   BUFFER_POOL != 'KEEP'
AND
   object_type IN ('TABLE','INDEX')
   ORDER BY 6 DESC



-----------------------------------
set echo off

select to_char(sysdate) time from dual;

spool off

-----------------------------------------------------------------------------
Prompt;
Prompt racdiag output files have been written to:;
Prompt;
host pwd
Prompt alert log and trace files are located in:;
column host_name format a12 tru
column name format a20 tru
column value format a60 tru
select distinct i.host_name, p.name, p.value
from v$instance i, v$parameter p
where p.inst_id = i.inst_id (+)
and p.name like '%_dump_dest' 
and p.name != 'core_dump_dest';









  
