
set feedback off
SET NEWPAGE NONE
SET PAGESIZE 1000
set lines 120
set echo off
set heading off

select to_char(ORIGINATING_TIMESTAMP, 'dd-mon-yyyy hh24:mi:ss'),
substr(MESSAGE_TEXT, 1, 300) message_text
from sys.ficheroalert
where (MESSAGE_TEXT like '%ORA-%'
or upper(MESSAGE_TEXT) like '%ERROR%'
or MESSAGE_TEXT like '%Starting up%')
and cast(ORIGINATING_TIMESTAMP as DATE) > sysdate - 2
and MESSAGE_TEXT not like '%ORA-29400%'
and MESSAGE_TEXT not like '%GATHER_STATS_JOB%'
and MESSAGE_TEXT not like '%error 19502%'
and MESSAGE_TEXT not like '%error 12545%'
and MESSAGE_TEXT not like '%ORA-1691%'
and MESSAGE_TEXT not like '%Fatal NI%'
and MESSAGE_TEXT not like '%ORA-15186 caught in ASM I/O path%'
and MESSAGE_TEXT not like '%ORA-12012%'
and MESSAGE_TEXT not like '%ORA-28%'
and MESSAGE_TEXT not like '%opiodr aborting process unknown ospid%'
and MESSAGE_TEXT not like '%se ha producido un error a nivel 2%'
and MESSAGE_TEXT not like '%error occurred at recursive SQL level 2%'
and MESSAGE_TEXT not like '%Tns error struct%'
and MESSAGE_TEXT not like '%SYS.I_WRI$_OPTSTAT_TAB_OBJ#_ST%';




