Set echo off
set timing on

Set Linesize 200
Set Pagesize 45
Set Desc Linenum On

Set Arraysize 1
Set Long 2000
Set Serveroutput On size 800000 ;

Set Termout  On

set echo on
-- chkoff
-- Previo a un immediate, comprobar:


REM Check to see any long query is running into the database while you are trying to shutdown the database.
Select f.R "Recovered", u.nr "Need Recovered" from (select count(block#) R , 1 ch from sys.fet$ ) f,(selectcount(block#) NR, 1 ch from sys.uet$) u where f.ch=u.ch;

REM Check to ensure large transaction is not going on while you are trying to shutdown the database.
Select * from v$session_longops where time_remaining>0 order by username;

REM Check the progress of the transaction that oracle is recovering.
Select sum(used_ublk) from v$transaction;

REM Check to ensure that any parallel transaction recovery is going on before performing shutdown immediate.
Select * from v$fast_start_transactions;

REM check transaction recovery keep on decreasing
Select * from v$fast_start_servers;
