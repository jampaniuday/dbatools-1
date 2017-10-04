set echo off
set heading on
column status format a10
col last_work_time format a8
set feedback off
set serveroutput on
set timing off

column username format a20
column sql_text format a200 word_wrapped



-- It shows you who's logged in and active -- and if 
--active, the statement they are executing (and the last et text shows you how long that 
--statement has been executing).  Currently, it shows only SQL that is executing right now, 
--just change the predicate from "where status = 'ACTIVE'" to "where status = status" if 
--you want to see the currently executing as well as LAST executed (in which case the last 
--et column text shows you how long they've been idle -- not how long that statement took 
--to execute):
-- fuente: http://asktom.oracle.com/pls/asktom/f?p=100:11%3A0%3A%3A%3A%3AP11_QUESTION_ID:497421739750
--
-- SQL that is executing right now
-- 


column status format a10
col last_work_time format a8
set feedback off
set serveroutput on
set timing off
set echo off

column username format a20
column sql_text format a200 word_wrapped

set serveroutput on size 1000000
declare
    x number;
begin
    for x in
    ( select username||'('||sid||','||serial#||
                ') ospid = ' ||  process ||
                ' program = ' || program username,
             to_char(LOGON_TIME,' Day HH24:MI') logon_time,
             to_char(sysdate,' Day HH24:MI') current_time,
             sql_address, LAST_CALL_ET
        from v$session
       --where status = 'ACTIVE'
	   where status = status
         and rawtohex(sql_address) <> '00'
         and username is not null order by last_call_et )
    loop
        for y in ( select max(decode(piece,0,sql_text,null)) ||
                          max(decode(piece,1,sql_text,null)) ||
                          max(decode(piece,2,sql_text,null)) ||
                          max(decode(piece,3,sql_text,null))
                               sql_text
                     from v$sqltext_with_newlines
                    where address = x.sql_address
                      and piece < 4)
        loop
            if ( y.sql_text not like '%listener.get_cmd%' and
                 y.sql_text not like '%RAWTOHEX(SQL_ADDRESS)%')
            then
                dbms_output.put_line( '--------------------' );
                dbms_output.put_line( x.username );
                dbms_output.put_line( x.logon_time || ' ' ||
                                      x.current_time||
                                      ' last et = ' ||
                                      x.LAST_CALL_ET);
                dbms_output.put_line(
                          substr( y.sql_text, 1, 250 ) );
            end if;
        end loop;
    end loop;
end;
/
col TERMINAL format a8
col PROGRAM format a30

Ttitle  ' [ User Activity -- v$session, v$process ]'  skip 2
select
   substr(a.spid,1,9) pid,
   substr(b.username,1,10) username,
   substr(b.sid,1,5) sid,
   substr(b.serial#,1,5) ser#,
   substr(b.machine,1,10) box,
   substr(b.osuser,1,8) os_user,
   substr(b.program,1,30) program,
   b.logon_time,
   b.last_call_et "LAST (SEC)",
   to_char(sysdate-(b.last_call_et/(60*60*24)),'hh24:mi:ss') last_work_time
from 
   v$session b, 
   v$process a
where
b.paddr = a.addr
--and type='USER'
order by last_call_et
/


ttitle off
btitle off
set timing on
set feedback on
