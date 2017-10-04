--vertam

set echo off
set timing off

Set Linesize 200
Set Pagesize 45
Set Desc Linenum On

Set Arraysize 1
Set Long 2000
Set Serveroutput On size 800000 ;

Set Feedback On
Set Verify   Off


Ttitle  ' [ tamaño bd total ]'  skip 1
-- tamaño bd total

select sum(BYTES)/1024/1024 MB from DBA_EXTENTS;


Ttitle  ' [ tamaño tablespaces ]'  skip 
-- tamaño tablespaces

set linesize 450
set pagesize 5000
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

Ttitle  ' [ tamaño esquemas ]'  skip 
-- tamaño esquemas

SELECT owner, SEGMENT_TYPE, SUM(BYTES)/1024/1024
FROM DBA_EXTENTS MB
GROUP BY owner, SEGMENT_TYPE
order by owner,size;

Ttitle  ' [ objetos por esquema y tam ]'  skip 
-- objetos por esquema y tamaños

select obj.owner "Owner", obj_cnt "Objects",
decode(seg_size, NULL, 0, seg_size) "size MB"
from ( select owner, count(*) obj_cnt from dba_objects group by owner) obj,
( select owner, ceil(sum(bytes)/1024/1024) seg_size from dba_segments group by owner) segment
where obj.owner = segment.owner(+)
order by 3 desc, 2 desc, 1;

Ttitle  ' [ Obejtos por tablespace y esquema ]'  skip 
set pages 350 lines 9000
SELECT tablespace_name, owner, segment_type "Object Type",
       COUNT(owner) "Number of Objects",
       ROUND(SUM(bytes) / 1024 / 1024, 2) "Total Size in MB"
FROM   sys.dba_segments
where tablespace_name not in ('SYSTEM','SYSAUX')
GROUP BY tablespace_name, owner, segment_type
ORDER BY tablespace_name, owner, segment_type;


Ttitle  ' [ tamaño top 10 tablas mas grandes ]'  skip 
-- tamaño top 10 tablas mas grandes

select owner, SEGMENT_NAME, sum(bytes)/1024/1024 Table_Allocation_MB 
from dba_segments
where segment_type in ('TABLE','INDEX')
and rownum < 10 group by owner, segment_name
order by 3 DESC;



Ttitle  ' [ tamaño asm ]'  skip 
--tamaño asm

-- TAMAÑOS: size, Tmaño total, tamaño libre
select GROUP_NUMBER, name, state, type, total_mb/1024 TOTAL_GB, free_mb  from v$asm_diskgroup;
--por disco:
col NAME format a13
col PATH format a15
select GROUP_NUMBER,NAME, total_mb/1024 TOTAL_GB,FREE_MB,PATH
from v$asm_disk;


Ttitle Off
Set Heading  On
Set Feedback On
Set Verify   On
Set Timing on