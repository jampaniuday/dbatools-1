
set pagesize 5000
set linesize 350
set echo off
SET LONG 90000

-- TABLESPACES DE UNDO - check undo 
Ttitle  ' [ TABLESPACES DE UNDO ]'  skip 1
col tablespace_name format a30
col file_name format a60
col autoextensible format a3
col MB format 9999999.99
col MaxMB format 9999999.99
set lines 200
select tablespace_name,file_name,bytes/(1024*1024) MB, autoextensible, maxbytes/(1024*1024) MaxMB
from dba_data_files where tablespace_name in
(select upper(value) from gv$parameter where name='undo_tablespace')
order by tablespace_name;  

-- Current undo USED and FREE space avaliable
Ttitle  ' [ Current undo USED and FREE space avaliable ]'  skip 1
select y.tablespace_name, y.totmb "Total size MB", round(x.usedmb*100/y.totmb,2) "% Used"
from
(
select a.tablespace_name, nvl(sum(bytes),0)/(1024*1024) usedmb
from dba_undo_extents a
where tablespace_name in (select upper(value) from gv$parameter where name='undo_tablespace')
and status in ('ACTIVE','UNEXPIRED')
group by a.tablespace_name
) x,
(
select b.tablespace_name, sum(bytes)/(1024*1024) totmb
from dba_data_files b
where tablespace_name in (select upper(value) from gv$parameter where name='undo_tablespace')
group by b.tablespace_name
) y
where y.tablespace_name=x.tablespace_name
order by y.tablespace_name;

-- Who is using your Undo space?
Ttitle  ' [ Who is using your Undo space? ]'  skip 1
set pagesize 400
set linesize 140
col name for a25
col program for a50
col username for a12
col osuser for a12
SELECT a.inst_id, a.sid, c.username, c.osuser, c.program, b.name,
a.value, d.used_urec, d.used_ublk
FROM gv$sesstat a, v$statname b, gv$session c, gv$transaction d
WHERE a.statistic# = b.statistic#
AND a.inst_id = c.inst_id
AND a.sid = c.sid
AND c.inst_id = d.inst_id
AND c.saddr = d.ses_addr
AND b.name = 'undo change vector size'
AND a.value > 0
ORDER BY a.value DESC

-- Snapshot too old?
Ttitle  ' [ Any Snapshot too old error? ]'  skip 1
select SSOLDERRCNT FROM v$undostat where SSOLDERRCNT!=0 order by begin_time;

--Identify No space to extend undo errors

select * from v$undostat where nospaceerrcnt !=0 order by begin_time;

-- Complete dump of the undo statistics information
Ttitle  ' [ Complete dump of the undo statistics information ]'  skip 1
select TO_CHAR(MIN(Begin_Time),'DD-MON-YYYY HH24:MI:SS') "Begin Time",
TO_CHAR(MAX(End_Time),'DD-MON-YYYY HH24:MI:SS') "End Time",
SUM(Undoblks)    "Total Undo Blocks Used",
SUM(Txncount)    "Total Num Trans Executed",
MAX(Maxquerylen)  "Longest Query(in secs)",
MAX(Maxconcurrency) "Highest Concurrent Txn count",
SUM(Ssolderrcnt),
SUM(Nospaceerrcnt), 
MAX(undoblks/((end_time-begin_time)*3600*24)) "UNDO_BLOCK_PER_SEC"
from V$UNDOSTAT;


-- Estimate the undo tablespace size required as well as the optimal Undo Retention
Ttitle  ' [ Estimate the undo tablespace size required ]'  skip 1
SELECT d.undo_size/(1024*1024) "ACTUAL UNDO SIZE [MByte]",
SUBSTR(e.value,1,25) "UNDO RETENTION [Sec]",
(TO_NUMBER(e.value) * TO_NUMBER(f.value) *
g.undo_block_per_sec) / (1024*1024)
"NEEDED UNDO SIZE [MByte]"
FROM (
SELECT SUM(a.bytes) undo_size
FROM v$datafile a,
v$tablespace b,
dba_tablespaces c
WHERE c.contents = 'UNDO'
AND c.status = 'ONLINE'
AND b.name = c.tablespace_name
AND a.ts# = b.ts#
) d,
v$parameter e,
v$parameter f,
(
SELECT MAX(undoblks/((end_time-begin_time)*3600*24))
undo_block_per_sec
FROM v$undostat
) g
WHERE e.name = 'undo_retention'
AND f.name = 'db_block_size'
/

-- Summarize active, expired and unexpired extents for current undo tablespaces.
Ttitle  ' [ Active, Expired and Unexpired extents for current undo ]'  skip 1
select tablespace_name,status, SUM (BYTES) / (1024 * 1024) AS size_mb  from dba_undo_extents
group by tablespace_name,status order by tablespace_name, status;

set echo on
Rem == ACTIVE: son transacciones con commit todavía pendientes
Rem == EXPIRED: son transacciones commiteadas y que ya se pueden sobreescribir
Rem == UNEXPIRED: son transacciones commiteadas pero que se guardan por un tiempo para dar consistencia de lectura a los datos
set echo off


-- Which sessions are using UNDO right now?
Ttitle  ' [ Which sessions are using UNDO right now ]'  skip 1
col sid_serial format a10
col orauser format a15
col PROGRAM format a30
col UNDOSEG format a12
col sql_id format a15
SELECT TO_CHAR(s.sid)||','||TO_CHAR(s.serial#) sid_serial,
NVL(s.username, 'None') orauser,
s.program, to_char(logon_time,'dd-MON-yyyy hh24:mi:ss'), round( (sysdate-logon_time), 2) * 24*60 MINS,
r.name undoseg,
t.used_ublk * TO_NUMBER(x.value)/1024||'K' "Undo"
FROM sys.v_$rollname    r,
sys.Gv_$session     s,
sys.Gv_$transaction t,
sys.Gv_$parameter   x
WHERE s.taddr = t.addr
AND r.usn   = t.xidusn(+)
AND x.name  = 'db_block_size';

-- Undo Recovery
-- set FAST_START_PARALLEL_ROLLBACK to high to give the SMON processes priority
Ttitle  ' [ Undo recovery ]'  skip 1
select PID,CPUTIME,state,
undoblocksdone,
undoblockstotal,
undoblocksdone / undoblockstotal * 100
from v$fast_start_transactions;


