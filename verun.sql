
set pagesize 9000
col sid heading 'SID' format 99999
col serial# heading 'SERIAL' format 9999999

select 
a.sid, 
a.serial#, 
a.username, 
a.machine, 
a.program, 
a.status, 
b.event, 
b.seconds_in_wait 
from v$session a, 
v$session_wait b 
where b.sid = a.sid 
and a.username is not null 
and status = 'ACTIVE' 
order by b.seconds_in_wait;