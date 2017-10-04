set pagesize 5000
set linesize 450
alter session set nls_date_format='DDMMYYYY HH24:MI:SS';

prompt
prompt  JOBS RUNING:
prompt

SELECT job,
sid id,
failures fallas,
Substr(To_Char(last_date,'DD-Mon-YYYY HH24:MI:SS'),1,20) ultimaFecha,
Substr(To_Char(this_date,'DD-Mon-YYYY HH24:MI:SS'),1,20) EstaFecha
FROM dba_jobs_running;

prompt
prompt  Listado JOBS - dba_jobs
prompt	 


set pages 1000
set lines 120
set linesize 450
set pagesize 5000
col job format 99999
col interval format a25
col what format a65
select job,LAST_DATE,SCHEMA_USER,BROKEN,FAILURES,NEXT_DATE,INTERVAL,TOTAL_TIME,WHAT
from dba_jobs
order by 3;