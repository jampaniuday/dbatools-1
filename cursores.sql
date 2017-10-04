COL SI FORMAT 99  HEAD 'Sid'
col ST format a55 head ' Sql Text' WORD

SET LONG 1000
SET VER OFF
SET PAGESIZE 22
set feed off

SELECT  H.SID                SI
,       S.sql_text           ST
,	  S.SORTS
,	  S.DISK_READS		"DISKR"
,	  S.BUFFER_GETS		"BUFFG"
,	s.executions
-- ,	  S.ROWS_PROCESSED	"ROWS"
FROM    V$OPEN_CURSOR O
,       V$SQLAREA     S
,       V$SESSION     H
WHERE   S.HASH_VALUE= S.HASH_VALUE
AND     S.ADDRESS = O.ADDRESS 
AND     H.SID = '&1'
AND     O.SADDR = H.SADDR
ORDER BY H.SID,O.USER_NAME
/
set feed on
set head on


--define usuario=&1
--and     o.user_name = upper('&usuario')