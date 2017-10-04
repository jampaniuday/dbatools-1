
set echo off
ttitle off
btitle off

set timing off
set feedback off
set heading on


col name     format a30
col username format a15
col osuser   format a15
col machine  format a12
set lines 132
set pages 1000

prompt
prompt  Top SQL activity% using SQL -- v$active_session_history
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


prompt
prompt  Top SQL -- v$sql
prompt

set serveroutput on size 1000000
declare
    x number;
begin
    for x in
    ( select sql_id,SESSION_ID,SESSION_SERIAL#,
		round(100*(count/sum(count) over ()),2) pct
		from (
		SELECT sql_id,SESSION_ID,SESSION_SERIAL#,count(*) count
		FROM v$active_session_history
		where sql_id is not null
		and (sysdate-cast (sample_time as date))*24*60<=5
		group by sql_id,SESSION_ID,SESSION_SERIAL#)
		order by 2 desc )
    loop
        for y in ( select distinct sql_text,USERS_EXECUTING,count(sql_text) nveces
                   from v$sql
                   where sql_id = x.sql_id
				   group by sql_text,USERS_EXECUTING)
        loop
                dbms_output.put_line( '--------------------' );
                dbms_output.put_line( 'SID: '||x.sql_id ||' USERS_EXECUTING: '|| y.USERS_EXECUTING ||' Num. Veces: '|| y.nveces);
				 dbms_output.put_line( '----' );
                dbms_output.put_line(substr( y.sql_text, 1, 250 ) );
        end loop;
    end loop;
end;
/
prompt
prompt

prompt
prompt .: Top 10 SESISONES
prompt

set lines 132
set trims on

col sid_serial        format a12         heading "Sid,Serial"
col USERNAME          format a8 trunc   heading "User"
col MACHINE           format a10 trunc   heading "Machine"
col OSUSER            format a10 trunc   heading "OS-User"
col logon             format a15         heading "Login Time"
col idle              format a8          heading "Idle"
col status            format a1          heading "S|t|a|t|u|s"
col lockwait          format a1          heading "L|o|c|k|w|a|i|t"
col module            format a35 trunc   heading "Module"                
                
select top_ten.tot_value
,      chr(39)||s.sid||','||s.serial#||chr(39) sid_serial
,      s.username
,      SUBSTR(s.status,1,1) status
,      s.lockwait
,      s.osuser
,      s.process
,      s.machine
,      to_char(s.logon_time,'DDth HH24:MI:SS') logon
,      floor(last_call_et/3600)||':'||
              floor(mod(last_call_et,3600)/60)||':'||
              mod(mod(last_call_et,3600),60)    IDLE
,      program||' '||s.module||' '||s.action  module
from 
   (select tot_value
    ,      sid
    from
	(select sum(stat.value) tot_value
        ,      s.sid
        from v$sesstat stat 
        ,    v$statname sname
		,    v$session s
        where s.sid = stat.sid
		and   stat.STATISTIC# = sname.STATISTIC#
        and   sname.name IN( 'consistent gets', 'db block gets'
                           , 'physical reads' , 'db block changes')
	and   s.type <> 'BACKGROUND'
	and   s.schemaname <> 'SYS'
	--and   s.status = 'ACTIVE'
        group by s.sid
        order by tot_value desc)
    where  rownum < 11)       top_ten
, v$session    s
where top_ten.sid = s.sid
order by 1 desc
/



set heading off
set timing on
set feedback on
set echo on
ttitle off