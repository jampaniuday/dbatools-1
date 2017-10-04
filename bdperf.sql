--		.: Script to find Oracle database performance

--			This single script provides the overall picture of the database 
-- 			in terms of Waits events, Active/Inactive killed sessions, Top 
--			Processes (physical I/O, logical I/O, memory and CPU processes), 
--			Top CPU usage by users, etc.

set serveroutput on
declare 
cursor c1 is select version
from v$instance;
cursor c2 is
    select
          host_name
       ,  instance_name
       ,  to_char(sysdate, 'HH24:MI:SS DD-MON-YY') currtime
       ,  to_char(startup_time, 'HH24:MI:SS DD-MON-YY') starttime
     from v$instance;
cursor c4 is
select * from (SELECT count(*) cnt, substr(event,1,50) event
FROM v$session_wait
WHERE wait_time = 0
AND event NOT IN ('smon timer','pipe get','wakeup time manager','pmon timer','rdbms ipc message',
'SQL*Net message from client')
GROUP BY event
ORDER BY 1 DESC) where rownum <6;
cursor c5 is
select round(sum(value)/1048576) as sgasize from v$sga;
cursor c6 is select round(sum(bytes)/1048576) as dbsize
from v$datafile;
cursor c7 is select 'top physical i/o process' category, sid,
       username, total_user_io amt_used,
       round(100 * total_user_io/total_io,2) pct_used
from (select b.sid sid, nvl(b.username, p.name) username,
             sum(value) total_user_io
      from v$statname c, v$sesstat a,
           v$session b, v$bgprocess p
      where a.statistic# = c.statistic#
      and p.paddr (+) = b.paddr
      and b.sid = a.sid
      and c.name in ('physical reads', 'physical writes',
                     'physical reads direct',
                     'physical reads direct (lob)',
                     'physical writes direct',
                     'physical writes direct (lob)')
      and b.username not in ('SYS', 'SYSTEM', 'SYSMAN', 'DBSNMP')
      group by b.sid, nvl(b.username, p.name)
      order by 3 desc),
     (select sum(value) total_io
      from v$statname c, v$sesstat a
      where a.statistic# = c.statistic#
      and c.name in ('physical reads', 'physical writes',
                       'physical reads direct',
                       'physical reads direct (lob)',
                       'physical writes direct',
                       'physical writes direct (lob)'))
where rownum < 2
union all
select 'top logical i/o process', sid, username,
       total_user_io amt_used,
       round(100 * total_user_io/total_io,2) pct_used
from (select b.sid sid, nvl(b.username, p.name) username,
             sum(value) total_user_io
      from v$statname c, v$sesstat a,
           v$session b, v$bgprocess p
      where a.statistic# = c.statistic#
      and p.paddr (+) = b.paddr
      and b.sid = a.sid
      and c.name in ('consistent gets', 'db block gets')
      and b.username not in ('SYS', 'SYSTEM', 'SYSMAN', 'DBSNMP')
      group by b.sid, nvl(b.username, p.name)
      order by 3 desc),
     (select sum(value) total_io
      from v$statname c, v$sesstat a,
           v$session b, v$bgprocess p
      where a.statistic# = c.statistic#
      and p.paddr (+) = b.paddr
 and b.sid = a.sid
      and c.name in ('consistent gets', 'db block gets'))
where rownum < 2
union all
select 'top memory process', sid,
       username, total_user_mem,
       round(100 * total_user_mem/total_mem,2)
from (select b.sid sid, nvl(b.username, p.name) username,
             sum(value) total_user_mem
      from v$statname c, v$sesstat a,
           v$session b, v$bgprocess p
      where a.statistic# = c.statistic#
      and p.paddr (+) = b.paddr
      and b.sid = a.sid
      and c.name in ('session pga memory', 'session uga memory')
      and b.username not in ('SYS', 'SYSTEM', 'SYSMAN', 'DBSNMP')
      group by b.sid, nvl(b.username, p.name)
      order by 3 desc),
     (select sum(value) total_mem
      from v$statname c, v$sesstat a
      where a.statistic# = c.statistic#
      and c.name in ('session pga memory', 'session uga memory'))
where rownum < 2
union all
select 'top cpu process', sid, username,
       total_user_cpu,
       round(100 * total_user_cpu/greatest(total_cpu,1),2)
from (select b.sid sid, nvl(b.username, p.name) username,
             sum(value) total_user_cpu
      from v$statname c, v$sesstat a,
           v$session b, v$bgprocess p
      where a.statistic# = c.statistic#
      and p.paddr (+) = b.paddr
      and b.sid = a.sid
      and c.name = 'CPU used by this session'
      and b.username not in ('SYS', 'SYSTEM', 'SYSMAN', 'DBSNMP')
      group by b.sid, nvl(b.username, p.name)
      order by 3 desc),
     (select sum(value) total_cpu
      from v$statname c, v$sesstat a,
           v$session b, v$bgprocess p
      where a.statistic# = c.statistic#
      and p.paddr (+) = b.paddr
      and b.sid = a.sid
      and c.name = 'CPU used by this session')
where rownum < 2;


cursor c8 is select username, sum(VALUE/100) cpu_usage_sec
from v$session ss, v$sesstat se, v$statname sn
where se.statistic# = sn.statistic#
and name like '%CPU used by this session%'
and se.sid = ss.sid
and username is not null
and username not in ('SYS', 'SYSTEM', 'SYSMAN', 'DBSNMP')
group by username
order by 2 desc;
begin
dbms_output.put_line ('Database Version');
dbms_output.put_line ('-----------------');
for rec in c1
loop
dbms_output.put_line(rec.version);
end loop;
dbms_output.put_line( chr(13) );
dbms_output.put_line('Hostname');
dbms_output.put_line ('----------');
for rec in c2
loop
     dbms_output.put_line(rec.host_name);
end loop;
dbms_output.put_line( chr(13) );
dbms_output.put_line('SGA Size (MB)');
dbms_output.put_line ('-------------');
for rec in c5
loop
     dbms_output.put_line(rec.sgasize);
end loop;
dbms_output.put_line( chr(13) );
dbms_output.put_line('Database Size (MB)');
dbms_output.put_line ('-----------------');
for rec in c6
loop
     dbms_output.put_line(rec.dbsize);
end loop;
dbms_output.put_line( chr(13) );
dbms_output.put_line('Instance start-up time');
dbms_output.put_line ('-----------------------');
for rec in c2 loop
 dbms_output.put_line( rec.starttime );
  end loop;
dbms_output.put_line( chr(13) );
  for b in
    (select total, active, inactive, system, killed
    from
       (select count(*) total from v$session)
     , (select count(*) system from v$session where username is null)
     , (select count(*) active from v$session where status = 'ACTIVE' and username is not null)


     , (select count(*) inactive from v$session where status = 'INACTIVE')
     , (select count(*) killed from v$session where status = 'KILLED')) loop
dbms_output.put_line('Active Sessions');
dbms_output.put_line ('---------------');
dbms_output.put_line(b.total || ' sessions: ' || b.inactive || ' inactive,' || b.active || ' active, ' || b.system || ' system, ' || b.killed || ' killed ');
  end loop;
  dbms_output.put_line( chr(13) );
 dbms_output.put_line( 'Sessions Waiting' );
  dbms_output.put_line( chr(13) );
dbms_output.put_line('Count      Event Name');
dbms_output.put_line('-----      -----------------------------------------------------');
for rec in c4 
loop
dbms_output.put_line(rec.cnt||'          '||rec.event);
end loop;
dbms_output.put_line( chr(13) );


dbms_output.put_line('-----      -----------------------------------------------------');


dbms_output.put_line('TOP Physical i/o, logical i/o, memory and CPU processes');
dbms_output.put_line ('---------------');
for rec in c7
loop
dbms_output.put_line (rec.category||': SID '||rec.sid||' User : '||rec.username||': Amount used : '||rec.amt_used||': Percent used: '||rec.pct_used);
end loop;


dbms_output.put_line('------------------------------------------------------------------');


dbms_output.put_line('TOP CPU users by usage');
dbms_output.put_line ('---------------');
for rec in c8
loop


dbms_output.put_line (rec.username||'--'||rec.cpu_usage_sec);
dbms_output.put_line ('---------------');
end loop;


end;
/

exec dbms_output.put_line('Tiempo respuesta m/s:')
select to_char(MAX(VALUE)*10,  'FM99999999999999.9999') retvalue FROM GV$METRIC where   
METRIC_NAME in ('SQL Service Response Time') AND GROUP_ID=2 ORDER BY 1;
exec dbms_output.put_line('---------------------------------');

------- TOP Reports session IO

column sid format a20

create or replace procedure session_io ( i_period in number default 10) is
	cursor c1 is
		select 
			sid,
			block_gets,
			consistent_gets,
			physical_reads,
			block_changes,
			consistent_changes
		from 
			v$sess_io
		order by
			sid;
	r	c1%rowtype;
	type s_type is table of c1%rowtype index by binary_integer;
	s_list s_type;
begin
	for r in c1 loop
		s_list(r.sid).block_gets := r.block_gets;
		s_list(r.sid).consistent_gets := r.consistent_gets;
		s_list(r.sid).physical_reads := r.physical_reads;
		s_list(r.sid).block_changes := r.block_changes;
		s_list(r.sid).consistent_changes := r.consistent_changes;
	end loop;
	dbms_lock.sleep (i_period);
	dbms_output.put_line('--- TOP Reports session IO ------');
	dbms_output.put_line('---------------------------------');
	dbms_output.put_line('Session I/O - ' || 
				to_char(sysdate,'dd-Mon hh24:mi:ss') 
	);
	dbms_output.put_line('Interval: ' || i_period || ' seconds');
	dbms_output.put_line('---------------------------------');
	dbms_output.put_line(
		'SID' ||
		lpad('Block Gets',12) ||
		lpad('Cons gets',12) ||
		lpad('Physical',12) ||
		lpad('Block chg',12) ||
		lpad('Cons Chgs',12)
	);
	dbms_output.put_line(
		'---' ||
		lpad('----------',12) ||
		lpad('----------',12) ||
		lpad('--------',12) ||
		lpad('---------',12) ||
		lpad('----------',12)
	);
	for r in c1 loop
		if (not s_list.exists(r.sid)) then
		    s_list(r.sid).block_gets := 0;
		    s_list(r.sid).consistent_gets := 0;
		    s_list(r.sid).physical_reads := 0;
		    s_list(r.sid).block_changes := 0;
		    s_list(r.sid).consistent_changes := 0;
		end if;
		if (
		       (s_list(r.sid).block_gets != r.block_gets)
		    or (s_list(r.sid).consistent_gets != r.consistent_gets)
		    or (s_list(r.sid).physical_reads != r.physical_reads)
		    or (s_list(r.sid).block_changes != r.block_changes)
		    or (s_list(r.sid).consistent_changes != r.consistent_changes)
		) then
			dbms_output.put(to_char(r.sid,'0000'));
			dbms_output.put(to_char( 
				r.block_gets - s_list(r.sid).block_gets,
					'999,999,990')
			);
			dbms_output.put(to_char( 
				r.consistent_gets - s_list(r.sid).consistent_gets,
					'999,999,990')
			);
			dbms_output.put(to_char( 
				r.physical_reads - s_list(r.sid).physical_reads,
					'999,999,990')
			);
			dbms_output.put(to_char( 
				r.block_changes - s_list(r.sid).block_changes,
					'999,999,990')
			);
			dbms_output.put_line(to_char( 
				r.consistent_changes - s_list(r.sid).consistent_changes,
					'999,999,990')
			);
		end if;
	end loop;
end session_io;
/


set serveroutput on
execute session_io;


exec dbms_output.put_line('Memoria libre:')
select pool, round(bytes/1024/1024,2) size_mb from v$sgastat where name like '%free memory%';

