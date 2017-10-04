Ttitle  ' [ Ver Sql - v$sql ]'  skip 2
set wrap on
set long 60000
set echo off
set verify off
set pagesize 50000
set lines 130
column sql_text heading "Texto SQL" format a80 word
column Programa format a20 word
col sid format 999
col Veces format 9999
col username format a10

alter session set nls_date_format='DDMMYYYY HH24:MI:SS';
prompt
prompt

select 
s.sid,s.username,
substr(s.program,instr(replace(s.program,'\',']'),']',-1)+1) Programa,
t.last_load_time,
t.last_active_time,
t.sql_fulltext,
t.old_hash_value
from 
 v$sqlarea t, 
 v$session s
where 
s.sql_address = t.address 
and s.sql_hash_value = t.hash_value
and s.sid = &1
/

-- Session stats by a specific SID
col username format A15;
col os_user format a40
select	nvl(ses.USERNAME,'ORACLE PROC') username,
	OSUSER os_user,
	PROCESS pid,
	ses.SID sid,
	SERIAL#,
	PHYSICAL_READS,
	BLOCK_GETS,
	CONSISTENT_GETS,
	BLOCK_CHANGES,
	CONSISTENT_CHANGES
from	v$session ses, 
	v$sess_io sio
where 	ses.SID = sio.SID
        and ses.SID = &1
order 	by PHYSICAL_READS, ses.USERNAME
/

set echo on