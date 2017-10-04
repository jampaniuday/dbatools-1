set linesize 450
set pagesize 5000
set echo off


-- TAMAÑOS: size, Tmaño total, tamaño libre
select GROUP_NUMBER, name, state, type, round(total_mb/1024,2) TOTAL_GB, round(free_mb/1024,2) free_GB,round((total_mb-free_mb)/total_mb*100,0) "%TOTAL" from v$asm_diskgroup;

SELECT * FROM V$FLASH_RECOVERY_AREA_USAGE;

col name format a40;
SELECT NAME, space_limit / 1024 / 1024 mb_space_limit,
       space_used / 1024 / 1024 mb_space_used,
       space_reclaimable / 1024 / 1024 mb_space_reclaimable,
       (space_limit - space_used + space_reclaimable) / 1024 / 1024 fra_available_mb,
       (space_limit - space_used + space_reclaimable) / space_limit * 100 PERCENT
FROM v$recovery_file_dest;


col BYTES           format 999,999,999,999
col MAXBYTES        format 999,999,999,999
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
maxbytes FROM dba_data_files GROUP BY tablespace_name
union all
SELECT tablespace_name,
SUM(bytes) bytes,
SUM(decode(autoextensible,'NO',bytes,'YES',maxbytes))
maxbytes FROM dba_temp_files GROUP BY tablespace_name) a,
(SELECT tablespace_name, SUM(bytes) bytes FROM dba_free_space 
GROUP BY tablespace_name) f
WHERE d.tablespace_name = a.tablespace_name(+)
AND d.tablespace_name = f.tablespace_name(+)
ORDER BY 6 DESC;
SELECT   A.tablespace_name tablespace, D.mb_total,
         SUM (A.used_blocks * D.block_size) / 1024 / 1024 mb_used,
         D.mb_total - SUM (A.used_blocks * D.block_size) / 1024 / 1024 mb_free
FROM     v$sort_segment A,
         (
         SELECT   B.name, C.block_size, SUM (C.bytes) / 1024 / 1024 mb_total
         FROM     v$tablespace B, v$tempfile C
         WHERE    B.ts#= C.ts#
         GROUP BY B.name, C.block_size
         ) D
WHERE    A.tablespace_name = D.name
GROUP by A.tablespace_name, D.mb_total;

