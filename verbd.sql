Set echo off
set ttitle off
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

Ttitle  ' [ verbd - v$session_wait ]'  skip 2

select event, state, count(*) from v$session_wait group by event, state order by 3 desc;


set timing on
Set Linesize 200
Set Pagesize 45
Set Desc Linenum On

Set Arraysize 1
Set Long 2000
Set Serveroutput On size 800000 ;

Set Heading  on
Set Feedback On
Set Verify   On
Set echo on
ttitle off