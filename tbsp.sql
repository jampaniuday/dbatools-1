--Ts bueno - tbsp2:
set linesize 450
set pagesize 5000
col BYTES           format 999,999,999,999
col MAXBYTES        format 999,999,999,999

	
--ASM:

-- TAMAÑOS: size, Tmaño total, tamaño libre
select GROUP_NUMBER, name, state, type, round(total_mb/1024,2) TOTAL_GB, round(free_mb/1024,2) free_GB,round((total_mb-free_mb)/total_mb*100,0) "%TOTAL" from v$asm_diskgroup;

--por disco:
col NAME format a13
col PATH format a15
select GROUP_NUMBER,NAME, total_mb/1024 TOTAL_GB,FREE_MB,PATH from v$asm_disk;

SELECT * FROM V$FLASH_RECOVERY_AREA_USAGE;

set lines 100
col name format a60
select	name
,	floor(space_limit / 1024 / 1024) "Size MB"
,	ceil(space_used  / 1024 / 1024) "Used MB"
from	v$recovery_file_dest
order by name
/

SELECT d.tablespace_name "Name",
--d.STATUS "Status",
--d.contents "Type",
--d.extent_management "Extent Management",
--d.initial_extent "Initial Extent",
TO_CHAR(NVL(a.bytes / 1024 / 1024, 0),'99,999,990.900') "Size (M)",
TO_CHAR(NVL(a.bytes - NVL(f.bytes, 0), 0)/1024/1024,'99,999,999.999') "Used (M)",
TO_CHAR(NVL((a.bytes - NVL(f.bytes, 0)) / a.bytes * 100, 0), '990.00') "Used %",
TO_CHAR(NVL(a.maxbytes / 1024 / 1024, 0),'99,999,990.900') "MaxSize (M)",
TO_CHAR(NVL((a.bytes - NVL(f.bytes, 0)) / a.maxbytes * 100, 0), '990.00') "Used % of Max"
FROM sys.dba_tablespaces d,
(SELECT tablespace_name, 
SUM(bytes) bytes, 
SUM(decode(autoextensible,'NO',bytes,'YES',maxbytes))
maxbytes FROM dba_data_files GROUP BY tablespace_name) a,
(SELECT tablespace_name, SUM(bytes) bytes FROM dba_free_space 
GROUP BY tablespace_name) f
WHERE d.tablespace_name = a.tablespace_name(+)
AND d.tablespace_name = f.tablespace_name(+)
ORDER BY 6 DESC;

select FILE_NAME, TABLESPACE_NAME, 
TO_CHAR(NVL(bytes / 1024 / 1024, 0),'99,999,990.900') "Size (M)",
AUTOEXTENSIBLE,TO_CHAR(NVL(maxbytes / 1024 / 1024, 0),'99,999,990.900')  "MAXBYTES" from dba_temp_files;
/