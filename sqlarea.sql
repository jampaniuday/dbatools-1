set echo off
Set Heading  On
set timing off
Set Feedback Off
Set Verify   Off

rem
rem     Script:        sqlarea.sql
rem     Author:        J.P.Lewis
rem     Dated:         Many moons ago
rem     Purpose:       Dump stats and text of recent expensive SQL
rem
rem     Notes:
rem     m_timestamp has been defined when this script is called
rem
rem     You can adjust the constants in the WHERE clause to suit your
rem     definition of what is expensive on your system.
rem
rem     The script tries to highlight code on the basis of absolute cost,
rem     and on cost per execution.  
rem
rem     Spot the little trick for avoiding divide by zero errors.  This
rem     can crop up very easily, especially if someone does an:
rem            alter system flush shared pool;
rem     The SQL can stay in the pool but with the set back to zero.
rem
set pagesize 999
set trimspool on
clear columns
clear breaks
column  sql_text format a78 word_wrapped
column  memory         noprint new_value m_memory
column  sorts          noprint new_value m_sorts
column  executions     noprint new_value m_executions
column  first_load_time noprint new_value m_first_load_time
column  invalidations  noprint new_value m_invalidations
column  parse_calls    noprint new_value m_parse_calls
column  disk_reads     noprint new_value m_disk_reads
column  buffer_gets    noprint new_value m_buffer_gets
column  rows_processed noprint new_value m_rows_processed
column  row_ratio      noprint new_value m_row_ratio
column  disk_ratio     noprint new_value m_disk_ratio
column  buffer_ratio   noprint new_value m_buffer_ratio
break on row skip page
set heading off
col sys_date new_value m_timestamp;
select CONCAT('/tmp/sqlarea.',to_char(sysdate,'yyyy_dd_mm_hh24_miss')) "Fichero Dump de SQL Area" from dual;
spool /tmp/sqlarea.&m_timestamp	


ttitle  -
        "First load time: " m_first_load_time -
        skip 1 -
        "Buffer gets:     " m_buffer_gets " ratio " m_buffer_ratio -
        skip 1 -
        "Disk reads:      " m_disk_reads  " ratio " m_disk_ratio -
        skip 1 -
        "Rows delivered   " m_rows_processed " ratio " m_row_ratio -
        skip 1 -
        "Executions       " m_executions -
        skip 1 -
        "Parses           " m_parse_calls -
        skip 1 -
        "Memory           " m_memory -
        skip 1 -
        "Sorts            " m_sorts -
        skip 1 -
        "Invalidations    " m_invalidations -
        skip 2

set termout off
select 
        sql_text,
        sharable_mem + persistent_mem + runtime_mem memory,
        sorts,
        executions,
        first_load_time,
        invalidations,
        parse_calls,
        disk_reads,
        buffer_gets,
        rows_processed,
        round(rows_processed/greatest(executions,1))  row_ratio,
        round(disk_reads/greatest(executions,1))      disk_ratio,
        round(buffer_gets/greatest(executions,1))     buffer_ratio
from v$sqlarea
where
        executions > 100
or      disk_reads > 1000
or      buffer_gets > 1000
or      rows_processed > 1000
order by
        executions * 250 + disk_reads * 25 + buffer_gets desc
;
spool off
ttitle off

set trimspool off
Set Heading  On
Set Feedback On
set timing on
Set Verify   On
set termout on
