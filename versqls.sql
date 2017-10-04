--set lines 125 pages 50000 long 200000000

set verify off lines 140 head on pagesize 300

column sql_text format a65
column username format a12
column osuser format a15

break on username on sid on osuser on status on spid

select S.USERNAME, s.sid,p.spid, s.osuser,s.status, sql_text
from v$sqltext_with_newlines t,V$SESSION s, v$process p
where t.address =s.sql_address
and t.hash_value = s.sql_hash_value 
and s.paddr = p.addr
order by s.sid,t.piece
/