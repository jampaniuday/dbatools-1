Set Heading  On
set echo off
Set Feedback Off
Set Verify   Off


Ttitle  ' [ STAT CURSOR ]'  skip 2
select to_char(100 * sess / calls, '999999999990.00') || '%' cursor_cache_hits,
to_char(100 * (calls - sess - hard) / calls, '999990.00') || '%' soft_parses,
to_char(100 * hard / calls, '999990.00') || '%' hard_parses
from ( select value calls from v$sysstat where name = 'parse count (total)' ),
( select value hard from v$sysstat where name = 'parse count (hard)' ),
( select value sess from v$sysstat where name = 'session cursor cache hits' )
/

Ttitle  ' [ TOTAL CURSORES POR SID ]'  skip 2
select sid, count(*) from v$open_cursor group by sid;

Ttitle  ' [ TOTAL CURSORES ]'  skip 2
select count(*) from v$open_cursor;


Ttitle  ' [ cuantos hay abiertos por sesion? ]'  skip 2 
select a.value, s.username, s.sid, s.serial#
from v$sesstat a, v$statname b, v$session s
where a.statistic# = b.statistic# 
and s.sid=a.sid and b.name = 'opened cursors current'
/
Ttitle  ' [ cuantos cursores abiertos por usuario y maquina? ]'  skip 2      
select sum(a.value) total_cur, avg(a.value) avg_cur, max(a.value) max_cur, s.username, s.machine
from v$sesstat a, v$statname b, v$session s 
where a.statistic# = b.statistic#  
and s.sid=a.sid and b.name = 'opened cursors current'
group by s.username, s.machine order by 1 desc
/
Ttitle  ' [ Que niveles hay? ]'  skip 2
select max(a.value) as highest_open_cur, p.value as max_open_cur 
from v$sesstat a, v$statname b, v$parameter p 
where a.statistic# = b.statistic#  
and b.name = 'opened cursors current' 
and p.name= 'open_cursors' group by p.value
/
Ttitle  ' [ % uso de del cacheo de cursores y cursores abiertos ]'  skip 2       
--Si el valor del SESSION_CACHED_CURSORS se encuentra en el 100%, deberíamos incrementar el valor del parámetro con normalidad.

select 'session_cached_cursors'  parameter,
lpad(value, 5)  value,
decode(value, 0, '  n/a', to_char(100 * used / value, '990') || '%')  usage
from
( select
    max(s.value)  used
  from
    sys.v_$statname  n,
    sys.v_$sesstat  s
  where
    n.name = 'session cursor cache count' and
    s.statistic# = n.statistic#
),
( select
    value
  from
    sys.v_$parameter
  where
    name = 'session_cached_cursors'
)
union all
select
'open_cursors',
lpad(value, 5),
to_char(100 * used / value,  '990') || '%'
from
( select
    max(sum(s.value))  used
  from
    sys.v_$statname  n,
    sys.v_$sesstat  s
  where
    n.name in ('opened cursors current', 'session cursor cache count') and
    s.statistic# = n.statistic#
  group by
    s.sid
),
( select
    value
  from
    sys.v_$parameter
  where
    name = 'open_cursors'
)
/

Ttitle Off
Set Heading  On
Set Feedback On
Set Verify   On