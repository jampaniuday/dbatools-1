set echo off
set timing off
set pagesize 1000
set feedback off


prompt
prompt  MEMORIA - TOTAL UTILIZADA
prompt


prompt
prompt  sga info
prompt

 
 -- SGA Info
select
  (select round(sum(bytes/1024/1024),0) from v$sgainfo where not REGEXP_LIKE(lower(name),'maximum|free|granule|startup')) "USED (MB)",
  (select bytes/1024/1024 from v$sgainfo where lower(name) like 'free%') "FREE (MB)",
  (select bytes/1024/1024 from v$sgainfo where lower(name) like 'maximum%') "MAX (MB)"
from dual;

prompt
prompt  pga info
prompt

-- PGA Info
SELECT ROUND(SUM(PGA_ALLOC_MEM)/1024/1024,0) "PGA USAGE (MB)" FROM V$PROCESS;


prompt
prompt  MEMORIA - @vermem - v$parameter, v$sgastat, v$sgainfo
prompt
set heading off
col NAME||':' format a21
column name  format a20
col value format a12
prompt
prompt  Memory Summary
prompt
select name ||': ',value/1024/1024 "SIZE MB"
from v$parameter
where name in ('sga_max_size','pga_aggregate_target','db_cache_size','shared_pool_size','large_pool_size','log_buffer','java_pool_size','sort_area_size')
/
set heading on
select round((sum(decode(name,'free memory',bytes,0))/sum(bytes))*100,2) "% Free SharedPool" from v$sgastat
/
select name,pool, bytes/1024/1024 "SIZE MB"
from v$sgastat 
where name = 'free memory'
union all
select name,pool, bytes/1024/1024 "SIZE MB"
from v$sgastat 
where name in  ('library cache','row cache','sql area','dictionary cache')
/
select name, bytes/1024/1024 "SIZE MB"
from v$sgainfo 
where name in ('Shared Pool Size','Large Pool Size','Java Pool Size')
/
set pagesize 132

column owner format a16
column name  format a36
column sharable_mem format 999,999,999
column executions   format 999,999,999
prompt
prompt  Top10 Memory Usage of Shared Pool Order - Biggest First
prompt
column name format a45
select  owner, name||' - '||type name, sharable_mem from v$db_object_cache
where sharable_mem > 10000
  and type in ('PACKAGE', 'PACKAGE BODY', 'FUNCTION', 'PROCEDURE')
  and rownum < 11
order by sharable_mem desc
/
prompt
prompt  Loads into Shared Pool  - Most Loads First
prompt
select  owner, name||' - '||type name, loads , sharable_mem from v$db_object_cache
where loads > 3
  and type in ('PACKAGE', 'PACKAGE BODY', 'FUNCTION', 'PROCEDURE')
order by loads desc
/
prompt
prompt  Executions of Objects in the  Shared Pool  - Most Executions First
prompt
select  owner, name||' - '||type name, executions from v$db_object_cache
where executions  > 100
  and type in ('PACKAGE', 'PACKAGE BODY', 'FUNCTION', 'PROCEDURE')
order by executions  desc
/
prompt
prompt Show the maximum PGA usage per process:
prompt
select max(pga_used_mem), max(pga_alloc_mem), max(pga_max_mem) from v$process;


prompt
prompt Tablas advice de PGA y SGA (v$*_target_advice)
prompt

select * from v$pga_target_advice order by pga_target_for_estimate;

select * from v$sga_target_advice;

!lpcs
set echo on

