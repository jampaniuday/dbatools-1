set echo off
set feedback off
set timing off
set head off
--set termout off
set trimspool on 
set verify off


select 'Buffer Cache Hit Ratio(> 80%) = '|| round ((1 - (pr.value / (bg.value + cg.value))) * 100, 2)
from v$sysstat pr, v$sysstat bg, v$sysstat cg
where pr.name = 'physical reads'
and bg.name = 'db block gets'
and cg.name = 'consistent gets'
/
select 'Dictionary Cache Hit Ratio(> 90%) = '|| round (sum (gets - getmisses) * 100 / sum (gets), 2)
from v$rowcache
/
select 'Sorts in Memory(high %) = '|| round ((mem.value / (mem.value + dsk.value)) * 100, 2)
from v$sysstat mem, v$sysstat dsk
where mem.name = 'sorts (memory)'
and dsk.name = 'sorts (disk)'
/
select 'Shared Pool Free (%)= '|| round ((sum (decode (name, 'free memory', bytes, 0)) 
/ sum (bytes)) * 100, 2)
from v$sgastat
/
select 'Shared Pool Reloads (low %)= '|| round (sum (reloads) / sum (pins) * 100, 2)
from v$librarycache
where namespace in ('SQL AREA', 'TABLE/PROCEDURE', 'BODY', 'TRIGGER')
/
select 'Library Cache Get Hit Ratio (> 95%) = '|| round (sum (gethits) / sum (gets) * 100, 2)
from v$librarycache
/
select 'Library Cache Pin Hit Ratio(> 99%) = '|| round (sum (pinhits) / sum (pins) * 100, 2)
from v$librarycache
/
select 'Recursive Calls vs Total Calls (low) = '|| round ((rcv.value / (rcv.value + usr.value)) * 100, 2)
from v$sysstat rcv, v$sysstat usr
where rcv.name = 'recursive calls'
and usr.name = 'user calls'
/
select 'Sort vs Total Table Scans (high)= '|| round ((shrt.value / (shrt.value + lng.value)) * 100, 2)
from  v$sysstat shrt, v$sysstat lng
where shrt.name = 'table scans (short tables)'
and lng.name = 'table scans (long tables)'
/
select 'Redo Space Wait Ratio (very low)= '|| round ((req.value / wrt.value) * 100, 2)
from v$sysstat req, v$sysstat wrt
where req.name = 'redo log space requests'
and wrt.name = 'redo writes'
/
select 'Redo Log Allocation Latch Contention(very low) = '|| round (greatest ((sum (decode (ln.name, 'redo allocation', 
  misses, 0))
/ greatest (sum (decode (ln.name, 'redo allocation', gets, 0)), 1)),
(sum (decode (ln.name, 'redo allocation', immediate_misses, 0))
/ greatest (sum (decode (ln.name, 'redo allocation', immediate_gets, 
  0))
+ sum (decode (ln.name, 'redo allocation', immediate_misses, 0)), 1))
) * 100, 2)
from v$latch l, v$latchname ln
where  l.latch# = ln.latch#
/
select 'Redo Log Copy Latch Contention(very Low) = '|| round (greatest ((sum (decode (ln.name, 'redo copy', misses, 0))
/ greatest (sum (decode (ln.name, 'redo copy', gets, 0)), 1)),
(sum (decode (ln.name, 'redo copy', immediate_misses, 0))
/ greatest (sum (decode (ln.name, 'redo copy', immediate_gets, 0))
+ sum  (decode (ln.name, 'redo copy', immediate_misses, 0)), 1))
) * 100, 2)
from v$latch l, v$latchname ln
where l.latch# = ln.latch#
/
select 'Chained Fetch Ratio(very low) = '|| round ((cont.value / (scn.value + rid.value)) * 100, 2)
from v$sysstat cont, v$sysstat scn, v$sysstat rid
where cont.name = 'table fetch continued row'
and scn.name = 'table scan rows gotten'
and rid.name = 'table fetch by rowid'
/
select 'Free List Contention(very low) = '|| round ((sum (decode (w.class, 'free list', count, 0)) 
/ (sum (decode (name, 'db block gets', value, 0))
+ sum (decode (name, 'consistent gets', value, 0)))) * 100, 2)
from v$waitstat w, v$sysstat
/
select 'CPU Parse Overhead(low) = '|| round ((prs.value / (prs.value + exe.value)) * 100, 2)
from v$sysstat prs, v$sysstat exe
where prs.name like 'parse count (hard)'
and exe.name = 'execute count'
/
select 'Willing-to-Wait Latch Gets(high) = '|| round (((sum (gets) - sum(misses)) / sum (gets)) * 100, 2)
from v$latch
/
select 'Immediate Latch Gets(high) = '|| round (((sum (immediate_gets) - sum (immediate_misses)) 
/ sum (immediate_gets)) * 100, 2)
from v$latch
/

set feedback on
set timing on
set head on
--set termout off
set trimspool off 
set verify on
set echo on



