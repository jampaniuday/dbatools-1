
Ttitle  ' [ BAKCUPS RMAN ]'  skip 2
alter session set nls_date_format='YYYY/MM/DD HH24:MI:SS';
col TIME_TAKEN_DISPLAY format a20
select input_type, start_time, end_time, time_taken_display,
input_bytes/1024/1024/1024 INPUTGB, output_bytes/1024/1024/1024 OUTPUTGB,
status, compression_ratio, output_bytes_per_sec/1024/1024 OUTPUT_MB_PER_SEC  from v$rman_backup_job_details;

Ttitle  ' [ EXP/IMP ]'  skip 2
prompt
prompt EXP/IMP check
prompt


-- sesiones
col username format a10
set linesize 150
col job_name format a20
col program format a25
SELECT TO_CHAR (SYSDATE, 'YYYY-MM-DD HH24:MI:SS') "DATE",
     s.program,
     s.sid,
     s.status,
     s.username,
     d.job_name,
     p.spid,
     s.serial#,
     p.pid
FROM V$SESSION s, V$PROCESS p, DBA_DATAPUMP_SESSIONS d
WHERE p.addr = s.paddr AND s.saddr = d.saddr;

-- queried V$SESSION_WAIT view to get the waiting event:

SELECT   w.sid, w.event, w.seconds_in_wait
FROM   V$SESSION s, DBA_DATAPUMP_SESSIONS d, V$SESSION_WAIT w
WHERE   s.saddr = d.saddr AND s.sid = w.sid;

-- info general
SELECT OWNER_NAME , JOB_NAME ,SESSION_TYPE from DBA_DATAPUMP_SESSIONS;

-- info con lso workers, para el paralelismo

SELECT V.STATUS, V.SID,V.SERIAL#,IO.BLOCK_CHANGES,EVENT, 
MODULE FROM V$SESS_IO IO,V$SESSION V WHERE IO.SID=V.SID
AND V.SADDR IN (SELECT SADDR FROM DBA_DATAPUMP_SESSIONS) ORDER BY SID;
 
SELECT v.status, v.SID,v.serial#,io.block_changes,event, module,v.sql_id 
FROM v$sess_io io,v$session v WHERE io.SID=v.SID AND v.saddr 
IN (SELECT saddr FROM dba_datapump_sessions) ORDER BY io.BLOCK_CHANGES;


prompt
prompt RAMN check
prompt

set pagesize 5000
set linesize 350
set echo off
SET LONG 90000

SELECT SID,OPERATION,STATUS,MBYTES_PROCESSED, START_TIME, END_TIME, OBJECT_TYPE, OUTPUT_DEVICE_TYPE 
FROM V$RMAN_STATUS WHERE STATUS = 'RUNNING';

-- Ocultar las operaciones completadas
SELECT sid, serial#, context, sofar, totalwork,
      round(sofar/totalwork*100,2) "% Complete", time_remaining
FROM GV$SESSION_LONGOPS
WHERE opname LIKE 'RMAN:%'
      AND opname NOT LIKE 'RMAN: aggregate%'
      AND totalwork != 0
   AND sofar!=totalwork;

SELECT S.CLIENT_INFO "Client Info", SL.OPNAME "Operation" ,trunc((TIME_REMAINING/60)/60) HORAS_RESTANTES,SL.MESSAGE, SL.SID, SL.SERIAL#, P.SPID "OS Process ID", SL.SOFAR "So Far", SL.TOTALWORK "Totalwork", ROUND(SL.SOFAR/SL.TOTALWORK*100,2) "% complete"
FROM V$SESSION_LONGOPS SL INNER JOIN V$SESSION S ON SL.SID = S.SID 
                          INNER JOIN V$PROCESS P ON P.ADDR = S.PADDR
AND OPNAME LIKE 'RMAN%'
AND TOTALWORK != 0
AND SOFAR <> TOTALWORK
/


Ttitle  ' [ RMAN operations in last 3 days (from V$RMAN_STATUS) ]'  skip 2
Set Linesize 200
Set Pagesize 45
Set Desc Linenum On
SELECT ROW_TYPE,  OPERATION, STATUS, OBJECT_TYPE, START_TIME, END_TIME 
FROM  v$rman_status
WHERE operation != 'RMAN'
AND start_time > (sysdate-2);
Ttitle off

Set Linesize 350
Set Pagesize 9000
