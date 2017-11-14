


set echo on

Rem ===========  ASH CPU by User
Rem =================================

SELECT sql_id, COUNT(*)
FROM gv$active_session_history ash, gv$event_name evt
WHERE ash.sample_time > SYSDATE - 5/(24*60)
AND ash.session_state = 'WAITING'
AND ash.event_id = evt.event_id
AND evt.wait_class = 'User I/O'
GROUP BY sql_id
ORDER BY COUNT(*) DESC;

Rem =================================


Rem ===========  ASH CPU Time
Rem =================================


SELECT ash.sql_id
,      ash.sql_child_number
,      s.sql_text
,      ash.sql_exec_start
,      ash.sql_exec_id
,      TO_CHAR(MIN(ash.sample_time),'hh24:mi:ss') AS min_sample_time
,      TO_CHAR(MAX(ash.sample_time),'hh24:mi:ss') AS max_sample_time
FROM   v$active_session_history ash
,      v$sql s
WHERE  ash.sql_id           = s.sql_id (+)
AND    ash.sql_child_number = s.child_number (+)
GROUP  BY
       ash.sql_id
,      ash.sql_child_number
,      s.sql_text
,      ash.sql_exec_start
,      ash.sql_exec_id
ORDER  BY
       MIN(ash.sample_time)
	   
Rem =================================	   



Rem ===========  ASH IO Waits
Rem =================================

SELECT sql_id, COUNT(*)
FROM gv$active_session_history ash, gv$event_name evt
WHERE ash.sample_time > SYSDATE - 5/(24*60)
AND ash.session_state = 'WAITING'
AND ash.event_id = evt.event_id
AND evt.wait_class = 'User I/O'
GROUP BY sql_id
ORDER BY COUNT(*) DESC
/


Rem =================================




Rem ===========  ASH Per Minute
Rem =================================

select
   to_char(round(sub1.sample_time, 'MI'), 'YYYY-MM-DD HH24:MI') as sample_minute,
   round(avg(sub1.on_cpu),1) as cpu_avg,
   round(avg(sub1.waiting),1) as wait_avg,
   round(avg(sub1.active_sessions),1) as act_avg,
   round( (variance(sub1.active_sessions)/avg(sub1.active_sessions)),1) as act_var_mean
from
   (    select
        sample_id,
        sample_time,
        sum(decode(session_state, 'ON CPU', 1, 0))  as on_cpu,
        sum(decode(session_state, 'WAITING', 1, 0)) as waiting,
        count(*) as active_sessions
     from
        dba_hist_active_sess_history
     where
        sample_time > sysdate - (&minutes/1440)
     group by
        sample_id,
        sample_time
   ) sub1
group by
   round(sub1.sample_time, 'MI')
order by
   round(sub1.sample_time, 'MI')
;


Rem =================================



Rem ===========  ASH SQL_ID CPU Use
Rem =================================

select * from (
select sql_id,  inst_id,
      sum(decode(vash.session_state,'ON CPU',1,0))  as "Number on CPU",
      sum(decode(vash.session_state,'WAITING',1,0)) as "Number Waiting on CPU"
from  gv$active_session_history vash
where sample_time > sysdate - 5 /( 60*24)
group by sql_id, inst_id
order by 3 desc
) where rownum < 11
/

Rem =================================




Rem ===========  ASH SQL_ID Waits
Rem =================================

select * from (
select sql_id,  inst_id,
   sum(decode(vash.session_state,'ON CPU',1,0)) as  "ON CPU",
   sum(decode(vash.session_state,'WAITING',1,0))  as "WAITING FOR CPU",
   event , count(distinct(session_id||session_serial#)) as "SESSION COUNT"
from  gv$active_session_history vash
where sample_time > sysdate - 5 /( 60*24)
group by event ,inst_id, sql_id , event
order by 4 desc
) where rownum <11
/


Rem =================================


Rem ===========  ASH Wait for CPU
Rem =================================
select * from (
select sql_id,  inst_id,
   sum(decode(vash.session_state,'ON CPU',1,0)) as  "ON CPU",
   sum(decode(vash.session_state,'WAITING',1,0))  as "WAITING FOR CPU",
   event , count(distinct(session_id||session_serial#)) as "SESSION COUNT"
from  gv$active_session_history vash
where sample_time > sysdate - 5 /( 60*24)
group by event ,inst_id, sql_id , event
order by 4 desc
) where rownum <11
/

Rem =================================