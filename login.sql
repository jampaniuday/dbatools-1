-- fichero login.sql (meterlo en $home/scripts)

SET pages 5000
SET LONG 50000
SET linesize 320
SET lines 320
SET serverout on size 500000
SET serveroutput ON
define _editor=vi
set line 320
SET FEEDBACK OFF
SET VERIFY OFF

-- Columnas para alias en las selects
column total format 999,999,990.00

alter session set nls_date_format="dd/mm/yyyy hh24:mi:ss";

-- prompt
define hostn="hostn"
column hostn noprint new_value hostn


define gname=idle
column global_name noprint new_value gname
select lower(user) || '@' ||
       substr( global_name, 1, decode( dot,
                                       0, length(global_name),
                                          dot-1) ) global_name
  from (select global_name, instr(global_name,'.') dot
          from global_name );
	

set sqlprompt '&gname SQL> ' 

SET head off
select 
   'Hostname : ' || host_name
   ,'Instance Name : ' || instance_name
   ,'Started At : ' || to_char(startup_time,'DD-MON-YYYY HH24:MI:SS') stime
   ,'Uptime : ' || floor(sysdate - startup_time) || ' days(s) ' ||
   trunc( 24*((sysdate-startup_time) - 
   trunc(sysdate-startup_time))) || ' hour(s) ' ||
   mod(trunc(1440*((sysdate-startup_time) - 
   trunc(sysdate-startup_time))), 60) ||' minute(s) ' ||
   mod(trunc(86400*((sysdate-startup_time) - 
   trunc(sysdate-startup_time))), 60) ||' seconds' uptime,
   host_name "hostn"
from 
sys.v_$instance;
exec dbms_output.put_line ('-------------------------------------------------------');
SET head on
@i
exec dbms_output.put_line ('-------------------------------------------------------');

SET timing ON
SET time on
SET serveroutput ON
SET FEEDBACK ON
SET VERIFY ON

