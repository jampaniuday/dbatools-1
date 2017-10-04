set echo off

prompt
prompt  .: Top sesiones con mas lecturas fisicas
prompt

set linesize 120
col os_user format a10
col username format a15

col pid format 9999999999
PROMPT SESSIONS SORTED BY PHYSICAL READS
PROMPT
select
  OSUSER os_user,username,
    PROCESS pid,
    ses.SID sid,
    SERIAL#,
    PHYSICAL_READS,
	CONSISTENT_GETS,
     BLOCK_CHANGES
 from       v$session ses,
   v$sess_io sio
  where      ses.SID = sio.SID
and username is not null
and status='ACTIVE'
order      by PHYSICAL_READS;


prompt
prompt  .: Top sesiones con mas lecturas logicas
prompt


set pagesize 200
set linesize 120
col segment_name format a20
col owner format a10

select segment_name,object_type,total_logical_reads
from ( select owner||'.'||object_name as segment_name,object_type,
value as total_logical_reads
from v$segment_statistics
where statistic_name in ('logical reads')
order by total_logical_reads desc)
where rownum <=10;


set echo on