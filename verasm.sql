set echo off

prompt
prompt .: ASM
prompt

-- ASM - Automatic Storage Management - ASM - volume manager
-- ASM SPACE USAGE BY FILETYPE
set term on

SET pages 32767 
SET lines 350
SET numf 999,999

COLUMN NAME HEAD "DiskGroup" FORMAT A15
COLUMN type HEAD "FileType" FORMAT A20
COLUMN SizeGB HEAD "Size|(GB)"

TTITLE LEFT "ASM SPACE USAGE BY FILETYPE" 

BREAK ON REPORT 
BREAK ON NAME
COMPUTE SUM LABEL 'Total' OF SizeGB FORMAT 99,999,999 ON NAME
COMPUTE SUM LABEL 'Total' OF SizeGB FORMAT 99,999,999 ON REPORT 

select dg.name
, f.type
, ROUND(sum(bytes)/1024/1024/1024) SizeGB
from v$asm_file f
, v$asm_diskgroup dg
where dg.group_number = f.group_number
group by dg.name, f.type 
ORDER BY dg.name, f.type ;


-- TAMAÑOS: size, Tmaño total, tamaño libre
select GROUP_NUMBER, name, state, type, total_mb/1024 TOTAL_GB, free_mb  from v$asm_diskgroup;
--por disco:
col NAME format a13
col PATH format a15
select GROUP_NUMBER,NAME, total_mb/1024 TOTAL_GB,FREE_MB,PATH
from v$asm_disk;

SELECT * FROM V$FLASH_RECOVERY_AREA_USAGE;

set lines 350
col name format a60
select	name
,	floor(space_limit / 1024 / 1024) "Size MB"
,	ceil(space_used  / 1024 / 1024) "Used MB"
from	v$recovery_file_dest
order by name
/


-- Ver los que hay en la flash
select sequence#,name,is_recovery_dest_file from V$ARCHIVED_LOG
where name != 'NULL'
order by sequence# desc;


--ASM DISKGROUPS
SELECT group_number, name, state, total_mb, free_mb, ROUND(free_mb/1024,2) free_gb, block_size, allocation_unit_size, type
FROM v$asm_diskgroup;

--ASM DISKS
COL path FORMAT a50
SELECT group_number, disk_number,  mount_status, header_status, mode_status, state, redundancy, total_mb, free_mb, name, path, create_date, mount_date
FROM v$asm_disk;

SELECT group_number, name, disk_number, FAILGROUP,PREFERRED_READ, mount_status, redundancy, total_mb, free_mb, path,  mount_date
FROM v$asm_disk;

--ASM OPERATIONS
SELECT group_number, operation, state, power, actual, ROUND(100*sofar/DECODE(est_work,0,1,est_work),2) avance, est_rate, est_minutes
FROM v$asm_operation;	



TTITLE OFF
set echo on









