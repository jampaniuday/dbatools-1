set timing off

-- ----------------------------------------------------------------------- ---
--   Performance                                                           ---
-- ----------------------------------------------------------------------- ---
set heading on
set echo off
set linesize 150
set pagesize 500


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

exec dbms_output.put_line('Eventos de Espera:')
select event, state, count(*) from v$session_wait group by event, state order by 3 desc;

exec dbms_output.put_line('Memoria libre:')
select pool, round(bytes/1024/1024,2) size_mb from v$sgastat where name like '%free memory%';





Ttitle off