set echo off
ttitle off
btitle off

set timing off
set feedback off
set heading on

col sid     format a30
col name     format a30
col username format a15
col osuser   format a15
col machine  format a12
set lines 132
set pages 1000

break on sid skip 1

Ttitle  ' [ Top CPU - v$sesstat,v$statname,v$session ]'  skip 2

select * from (
select a.sid
,      c.username
,      c.osuser
,      c.machine
,      b.name 
,      a.value
from   v$sesstat  a
,      v$statname b
,      v$session  c
where a.STATISTIC# = b.STATISTIC#
and   a.sid = c.sid
and   b.name like '%CPU%'
order by a.value desc)
where rownum < 11
/

set echo off
ttitle off
btitle off

set timing on
set feedback on
set heading on


col name     format a30
col username format a15
col osuser   format a15
col machine  format a12
set lines 132
set pages 1000

prompt
prompt  Top SQL CPU activity% using SQL -- v$active_session_history
prompt

select sql_id,SESSION_ID,SESSION_SERIAL#,
round(100*(count/sum(count) over ()),2) pct
from (
SELECT sql_id,SESSION_ID,SESSION_SERIAL#,count(*) count
FROM v$active_session_history
where sql_id is not null
and (sysdate-cast (sample_time as date))*24*60<=5 
group by sql_id,SESSION_ID,SESSION_SERIAL#)
order by 2 desc
/
ttitle off


set heading off
set timing on
set feedback on
set echo on
ttitle off