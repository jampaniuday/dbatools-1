Set echo off
set timing off
Set Linesize 200
Set Pagesize 45
Set Desc Linenum On

Set Arraysize 1
Set Long 2000
Set Serveroutput On size 800000 ;

Set Heading  on
Set Feedback Off
Set Verify   Off


rem
rem     Script:        filestat.sql
rem     Author:        J.P.Lewis
rem     Dated:         Lost in the mists of time
rem     Purpose:       Report v$filestat
rem
rem     Notes:
rem     m_timestamp has been defined before this report is called
rem     usually through a loop which calculates the date and time.
rem
rem     Spot the little fix for avoiding the divide by zero error.
rem
rem     The headings have no spaces to cater for awk further down.
rem
rem     The code has to be run by a user who can see v$filestat
rem

Ttitle  ' [ I/O Data Files - v$filestat,dba_data_files]'  skip 1
set trimspool on
set pagesize 1023

ttitle off
btitle off
clear columns
clear breaks
column  file#          format  9999   heading "File"
column  phyrds         format  99999999999 heading "Reads"
column  FILE_NAME 	   format   	    a60 heading "File" 	
column  phyblkrd       format  99999999999 heading "Blks_Rd"
column  readtim        format  9999.999  heading "Avg_Time"
column  phywrts        format  9999999 heading "Writes"
column  phyblkwrt      format  9999999 heading "Blks_wrt"
column  writetim       format  99.999  heading "Avg_Time"
col sys_date new_value m_timestamp;
--select to_char(sysdate,'yyyy_dd_mm_hh24_miss') sys_date from dual;
--spool /tmp/filestat.&m_timestamp
select 
        f.file#,
		d.FILE_NAME,
        f.phyrds,
        f.phyblkrd,
        round(readtim/decode(f.phyrds,0,1,f.phyrds),3)    readtim,
        f.phywrts,
        f.phyblkwrt,
        round(writetim/decode(f.phywrts,0,1,f.phywrts),3) writetim
from v$filestat f, dba_data_files d
where f.file# = d.FILE_ID and
rownum < 5
order by phyrds desc
/
--spool off

Set Heading  on
Set Feedback on
Set Verify   on
Set echo on



