
set echo off

prompt
prompt  Number of memory SORTS and disk SORTS, and the ratio of disk to memory sorts.
prompt


set pages 9999;
column mydate heading 'Yr.  Mo Dy  Hr.' format a16
column sorts_memory  format 999,999,999
column sorts_disk    format 999,999,999
column ratio         format .99999

select
   to_char(snap_time,'yyyy-mm-dd HH24') mydate,
   newmem.value-oldmem.value sorts_memory,
   newdsk.value-olddsk.value sorts_disk,
   ((newdsk.value-olddsk.value)/(newmem.value-oldmem.value)) ratio
from
   perfstat.stats$sysstat oldmem,
   perfstat.stats$sysstat newmem,
   perfstat.stats$sysstat newdsk,
   perfstat.stats$sysstat olddsk,
   perfstat.stats$snapshot   sn
where
   newdsk.snap_id = sn.snap_id
and
   olddsk.snap_id = sn.snap_id-1
and
   newmem.snap_id = sn.snap_id
and
   oldmem.snap_id = sn.snap_id-1
and
   oldmem.name = 'sorts (memory)'
and
   newmem.name = 'sorts (memory)'
and
   olddsk.name = 'sorts (disk)'
and
   newdsk.name = 'sorts (disk)'
and
   newmem.value-oldmem.value > 0
   and
   newdsk.value-olddsk.value > 100
;

prompt
prompt  SORTS average sorts, ordered by hour of the day
prompt


set pages 9999;

column sorts_memory  format 999,999,999
column sorts_disk    format 999,999,999
column ratio         format .99999

select
   to_char(snap_time,'HH24'),
   avg(newmem.value-oldmem.value) sorts_memory,
   avg(newdsk.value-olddsk.value) sorts_disk
from
   perfstat.stats$sysstat oldmem,
   perfstat.stats$sysstat newmem,
   perfstat.stats$sysstat newdsk,
   perfstat.stats$sysstat olddsk,
   perfstat.stats$snapshot   sn
where
   newdsk.snap_id = sn.snap_id
and
   olddsk.snap_id = sn.snap_id-1
and
   newmem.snap_id = sn.snap_id
and
   oldmem.snap_id = sn.snap_id-1
and
   oldmem.name = 'sorts (memory)'
and
   newmem.name = 'sorts (memory)'
and
   olddsk.name = 'sorts (disk)'
and
   newdsk.name = 'sorts (disk)'
and
   newmem.value-oldmem.value > 0
group by
   to_char(snap_time,'HH24')
;

prompt
prompt  SORTS averages by the day of the week.
prompt


set pages 9999;

column sorts_memory  format 999,999,999
column sorts_disk    format 999,999,999
column ratio         format .99999

select
   to_char(snap_time,'day')       DAY,
   avg(newmem.value-oldmem.value) sorts_memory,
   avg(newdsk.value-olddsk.value) sorts_disk
from
   perfstat.stats$sysstat oldmem,
   perfstat.stats$sysstat newmem,
   perfstat.stats$sysstat newdsk,
   perfstat.stats$sysstat olddsk,
   perfstat.stats$snapshot   sn
where
   newdsk.snap_id = sn.snap_id
and
   olddsk.snap_id = sn.snap_id-1
and
   newmem.snap_id = sn.snap_id
and
   oldmem.snap_id = sn.snap_id-1
and
   oldmem.name = 'sorts (memory)'
and
   newmem.name = 'sorts (memory)'
and
   olddsk.name = 'sorts (disk)'
and
   newdsk.name = 'sorts (disk)'
and
   newmem.value-oldmem.value > 0
group by
   to_char(snap_time,'day')
;