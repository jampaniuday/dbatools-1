

alter session set nls_date_format='YYYY-MON-DD HH24:MI:SS'; 

select name,open_mode,database_role,db_unique_name,protection_mode from v$database;



select message, timestamp 
from v$dataguard_status 
where severity in ('Error','Fatal') 
order by timestamp; 

select inst_id, process, status, thread#, sequence#, block#, blocks from gv$managed_standby where process in ('RFS','LNS','MRP0'); 

select 'Last applied  : ' Logs, to_char(next_time,'DD-MON-YY:HH24:MI:SS') Time
from v$archived_log
where sequence# = (select max(sequence#) from v$archived_log where applied='YES')
union
select 'Last received : ' Logs, to_char(next_time,'DD-MON-YY:HH24:MI:SS') Time
from v$archived_log
where sequence# = (select max(sequence#) from v$archived_log);

select
NAME Name,
VALUE Value,
UNIT Unit
from v$dataguard_stats
union
select null,null,' ' from dual
union
select null,null,'Time Computed: '||MIN(TIME_COMPUTED)
from v$dataguard_stats;

select to_char(max(last_time),'DD-MON-YYYY HH24:MI:SS') "Redo onsite" from v$standby_log;


select sequence#,first_time,next_time from v$archived_log order by sequence#;
select sequence#,first_time,next_time,applied from v$archived_log order by sequence#;