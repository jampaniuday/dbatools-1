set heading on
set linesize 500
set echo off
Set Termout  On
Set Timing off
SET PAGESIZE 1000
SET VERIFY OFF
	
Ttitle  ' [ Who is holding locks for more than one minute - V_$LOCKED_OBJECT ALL_OBJECTS V_$SESSION ]'  skip 2
col sid format a5
col locker format a10
col OBJECT_NAME format a20
col LOCKED_MODE format a20 
select Lpad(session_id,5) "sid",SERIAL#  "Serial",substr(OBJECT_NAME,1,20) "Object",
Lpad(substr(ORACLE_USERNAME,1,10),10) "Locker",NVL(lockwait,'ACTIVE') "Wait",DECODE(LOCKED_MODE,
    2, 'ROW SHARE',
    3, 'ROW EXCLUSIVE',
    4, 'SHARE',
    5, 'SHARE ROW EXCLUSIVE',
    6, 'EXCLUSIVE',  'UNKNOWN') "Lockmode",
  OBJECT_TYPE "Type"
FROM SYS.V_$LOCKED_OBJECT A,SYS.ALL_OBJECTS B,SYS.V_$SESSION c
WHERE A.OBJECT_ID = B.OBJECT_ID AND C.SID = A.SESSION_ID ORDER BY 1 asc, 5 desc;

Ttitle  ' [ Quien Bloquea a Quien]'  skip 2
select s1.username || '@' || s1.machine
|| ' ( SID=' || s1.sid || ' ) is blocking '
|| s2.username || '@' || s2.machine || ' ( SID=' || s2.sid || ' ) ' AS blocking_status
from v$lock l1, v$session s1, v$lock l2, v$session s2
where s1.sid=l1.sid and s2.sid=l2.sid
and l1.BLOCK=1 and l2.request > 0
and l1.id1 = l2.id1
and l2.id2 = l2.id2
/

Ttitle  ' [ Eliminando Sesiones Bloqueantes ]'  skip 2
-- Si queremos eliminar sessiones bloqueantes - killing block session - kill block ses

select  'alter system kill session ''' ||session_id||','||SERIAL#||''';' from SYS.V_$LOCKED_OBJECT A,SYS.ALL_OBJECTS B,SYS.V_$SESSION c
where A.OBJECT_ID = B.OBJECT_ID AND C.SID = A.SESSION_ID;

Ttitle  ' [ gv$ LOCKS ]'  skip 2

col object_name format a25
col sid_serial format a12
col osuser format a12
col ctime format 99999
col inst format a12
col machine format a18
col lock_mode format a14
col user_status format a14
SELECT DECODE (l.BLOCK, 0, 'Waiting', 'Blocking ->') user_status
,CHR (39) || s.SID || ',' || s.serial# || CHR (39) sid_serial
,(SELECT instance_name FROM gv$instance WHERE inst_id = l.inst_id)
inst
,s.SID
--,s.PROGRAM
,s.osuser
,s.machine
,DECODE (l.TYPE,'RT', 'Redo Log Buffer','TD', 'Dictionary'
,'TM', 'DML','TS', 'Temp Segments','TX', 'Transaction'
,'UL', 'User','RW', 'Row Wait',l.TYPE) lock_type
--,id1
--,id2
,DECODE (l.lmode,0, 'None',1, 'Null',2, 'Row Share',3, 'Row Excl.'
,4, 'Share',5, 'S/Row Excl.',6, 'Exclusive'
,LTRIM (TO_CHAR (lmode, '990'))) lock_mode
,ctime
--,DECODE(l.BLOCK, 0, 'Not Blocking', 1, 'Blocking', 2, 'Global') lock_status
,object_name
FROM 
   gv$lock l
JOIN 
   gv$session s
ON (l.inst_id = s.inst_id
AND l.SID = s.SID)
JOIN gv$locked_object o
ON (o.inst_id = s.inst_id
AND s.SID = o.session_id)
JOIN dba_objects d
ON (d.object_id = o.object_id)
WHERE (l.id1, l.id2, l.TYPE) IN (SELECT id1, id2, TYPE
FROM gv$lock
WHERE request > 0)
ORDER BY id1, id2, ctime DESC; 



set heading on
set linesize 500
set echo on
Set Termout  On
Set Timing on
SET PAGESIZE 1000
SET VERIFY On
Ttitle  Off

