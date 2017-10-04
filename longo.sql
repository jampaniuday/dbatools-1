set echo off
set feedback off
set timing off
--set termout off
set trimspool on 
set verify off

Ttitle  ' [ Long running operations - v$session_longops ]'  skip 2
SELECT SID, SERIAL#, opname, SOFAR, TOTALWORK,
ROUND(SOFAR/TOTALWORK*100,2) "COMPLETE%", ELAPSED_SECONDS "EMPEZO(sec)",
TIME_REMAINING/60 "ESTIMACION (sec)"
FROM   V$SESSION_LONGOPS
WHERE
TOTALWORK != 0
AND    SOFAR != TOTALWORK
order by 1;

set feedback on
set timing on
--set termout off
set trimspool off 
set verify on
TTITLE OFF
set echo on

