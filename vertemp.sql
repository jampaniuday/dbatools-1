
set echo off

COL SEGMENT_NAME FORMAT A30
col tablespace_name format a20
col tablespace format a20
col username format a20
col file_name format a50
set lines 120

col FILE_NAME       format a50
col TABLESPACE_NAME format a15
col BYTES           format 999,999,999,999
col MAXBYTES        format 999,999,999,999
set linesize 1000


SELECT   A.tablespace_name tablespace, D.mb_total,
         SUM (A.used_blocks * D.block_size) / 1024 / 1024 mb_used,
         D.mb_total - SUM (A.used_blocks * D.block_size) / 1024 / 1024 mb_free
FROM     v$sort_segment A,
         (
         SELECT   B.name, C.block_size, SUM (C.bytes) / 1024 / 1024 mb_total
         FROM     v$tablespace B, v$tempfile C
         WHERE    B.ts#= C.ts#
         GROUP BY B.name, C.block_size
         ) D
WHERE    A.tablespace_name = D.name
GROUP by A.tablespace_name, D.mb_total;

select FILE_ID,FILE_NAME,TABLESPACE_NAME, BYTES, MAXBYTES from  dba_temp_files;

select t.file_name,h.BYTES_USED/1024/1024, h.BYTES_FREE/1024/1024
from dba_temp_files t, V$TEMP_SPACE_HEADER h
where t.file_id=h.file_id
order by 1;

SELECT tablespace_name, 
	extent_size, 
	total_extents, 
	used_extents,          
	free_extents, 
	max_used_size,
	used_blocks
FROM v$sort_segment;  

   SELECT s.sid,
	  s.serial#,
	s.username, 
	u.tablespace, 
	u.contents, 
	u.extents, 
	u.blocks       
FROM v$session s, 
	v$sort_usage u       
WHERE s.saddr=u.session_addr
order by s.sid; 


Ttitle  ' [ General usage -- v$sort_usage, dba_tablespaces, v$session ses]'  skip 2

set pages 999 lines 100
col username format a15
col mb format 999,999
select  su.username
,       ses.sid 
,       ses.serial#
,		ses.status
,		ses.osuser
,       su.tablespace
,       ceil((su.blocks * dt.block_size) / 1048576) MB
from    v$sort_usage    su
,       dba_tablespaces dt
,       v$session ses
where   su.tablespace = dt.tablespace_name
and     su.session_addr = ses.saddr
/

col SPID 	   format a7
col SID_SERIAL format a12
col OSUSER format a15
col PROGRAM format a15


Ttitle  ' [ Sort Space Usage by Session]'  skip 2		  

SELECT   S.sid || ',' || S.serial# sid_serial, S.username, S.osuser, P.spid,
         S.program, SUM (T.blocks) * TBS.block_size / 1024 / 1024 mb_used, T.tablespace,
         COUNT(*) sort_ops
FROM     v$sort_usage T, v$session S, dba_tablespaces TBS, v$process P
WHERE    T.session_addr = S.saddr
AND      S.paddr = P.addr
AND      T.tablespace = TBS.tablespace_name
GROUP BY S.sid, S.serial#, S.username, S.osuser, P.spid, S.module,
         S.program, TBS.block_size, T.tablespace
ORDER BY sid_serial;

Ttitle  ' [ Sort Space Usage by Statement ]'  skip 2	

SELECT   S.sid || ',' || S.serial# sid_serial, S.username,
         T.blocks * TBS.block_size / 1024 / 1024 mb_used, T.tablespace,
         T.sqladdr address, Q.hash_value, Q.sql_text
FROM     v$sort_usage T, v$session S, v$sqlarea Q, dba_tablespaces TBS
WHERE    T.session_addr = S.saddr
AND      T.sqladdr = Q.address (+)
AND      T.tablespace = TBS.tablespace_name
ORDER BY S.sid;

set echo on


/*
select segment_name,bytes/1024,tablespace_name
from dba_segments
where segment_type='TEMPORARY'
/
*/