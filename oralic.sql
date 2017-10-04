set pages 9000 lines 100
set echo off verify off feedback off
set feedback off serveroutput on
col sys_date new_value m_timestamp;
col global_name new_value gname;
select to_char(sysdate,'yyyy_dd_mm_hh24_miss') sys_date from dual;
select  global_name  from global_name;
spool /tmp/oralic.&gname..&m_timestamp..txt
--spool "C:/oralic.&gname..&m_timestamp..txt"


prompt INFO: NEED EXTRA LICENSE
prompt ------------------------------
prompt Advanced Compression
prompt Advanced Security
prompt Advanced Analytics
prompt RAC One Node
prompt Real Application Clusters
prompt Real Application Testing
prompt Partitioning
prompt Diagnostics Pack
prompt Tuning Pack
prompt Active Data Guard
prompt Database Vault
prompt Label Security
prompt OLAP
prompt Spatial and Graph
prompt Change Management Pack
prompt Configuration Management Pack
prompt Data Masking and Subsetting Pack
prompt Provisioning and Patch Automation Pack
prompt
prompt Oracle Advanced Compression:
prompt 		Backup ZLIB Compression,Backup LOW Compression,Backup MEDIUM Compression,Backup HIGH Compression,
prompt 		SecureFile Compression (user),SecureFile Deduplication (user),HeapCompression,Hybrid Columnar Compression
prompt 		Oracle Utility Datapump
prompt 		Hybrid Columnar Compression
prompt 

PROMPT ===================================== 1)Uso Licencias Opciones RAC,Particionamineto,spatial,etc..
prompt
prompt ==== COUNT: SESSIONS, USERS, CPU
select * from v$license;
prompt
prompt ================================
select banner from v$version where BANNER like '%Edition%';
prompt ================================
prompt PARTICIONAMIENTO?
select decode(count(*), 0, 'No', 'Yes') Partitioning
from ( select 1 
from dba_part_tables
where owner not in ('SYSMAN', 'SH', 'SYS', 'SYSTEM')
and rownum = 1 );
prompt ================================
prompt SPATIAL?
select decode(count(*), 0, 'No', 'Yes') Spatial
from ( select 1
from all_sdo_geom_metadata 
where rownum = 1 );
prompt ================================
prompt RAC?
select decode(count(*), 0, 'No', 'Yes') RAC
from ( select 1 
from v$active_instances 
where rownum = 1 );
prompt ================================
prompt Active Data Guard Used?
select 'Using Active Data Guard' ADG
from v$managed_standby m, v$database d
where m.process like 'MRP%';
prompt ================================
prompt OPTIONS?
--# nearly the same as you proposed
Col name  format a50 heading "Option"
Col value format a5  heading "?"      justify center wrap
Select parameter name, value
from v$option 
order by 2 desc, 1;
prompt ================================
prompt SECURE FILES?  CLOB column is stored as SecureFile ? 
col column_name format a20
col table_name format a30
col owner format a10
select owner,table_name,column_name from dba_lobs where securefile = 'YES';
prompt ================================
prompt USAGE?
Set feedback off
Set linesize 122
Col name             format a45     heading "Feature"
Col version          format a10     heading "Version"
Col detected_usages  format 999,990 heading "Detected|usages"
Col currently_used   format a06     heading "Curr.|used?"
Col first_usage_date format a10     heading "First use"
Col last_usage_date  format a10     heading "Last use"
Col nop noprint
Break on nop skip 1 on name
Select decode(detected_usages,0,2,1) nop,
       name, version, detected_usages, currently_used,
       to_char(first_usage_date,'DD/MM/YYYY') first_usage_date, 
       to_char(last_usage_date,'DD/MM/YYYY') last_usage_date
from dba_feature_usage_statistics
where last_usage_date is not null
order by nop, 1, 2;
PROMPT
PROMPT ===================================== 2)Uso Licencias AWR
PROMPT
show parameter CONTROL_MANAGEMENT_PACK_ACCESS
prompt DISABLE: ALTER SYSTEM SET CONTROL_MANAGEMENT_PACK_ACCESS="NONE" SCOPE=BOTH;
PROMPT
PROMPT ===================================== 3)Uso Licencias Advanced Compression Option
PROMPT
PROMPT -- INFO: Advanced Compression Option (ACO):
PROMPT 1- OLTP Table Compression
PROMPT 2- LOB Compression
PROMPT 3- Data Pump Compression
PROMPT 4- Fast ZLIB RMAN Compression
PROMPT 5- Data Guard Log Transport Compression
prompt COMPRESSION?
SELECT name,
detected_usages detected, 
FEATURE_INFO,
total_samples samples,
currently_used  used, 
to_char(last_sample_date,'MMDDYYYY:HH24:MI') last_sample,
sample_interval interval
FROM dba_feature_usage_statistics
where detected_usages > 0
and name like ('%Compression%') or
name in ('Oracle Utility Datapump','Data Guard');
PROMPT --Necesita licencia:
PROMPT --Backup ZLIB Compression,Backup LOW Compression,Backup MEDIUM Compression,Backup HIGH Compression,
PROMPT --SecureFile Compression (user),SecureFile Deduplication (user),HeapCompression,Hybrid Columnar Compression
PROMPT --Oracle Utility Datapump 
PROMPT --Data Guard
PROMPT --Hybrid Columnar Compression
PROMPT
SELECT table_name,owner, compression, compress_for FROM dba_tables where compression not like ('DISABLED');
SELECT table_name,TABLE_OWNER, partition_name, compression, compress_for FROM dba_tab_partitions where compression not in ('DISABLED','NONE');
SELECT TABLESPACE_NAME,def_tab_compression, compress_for FROM dba_tablespaces;
select OWNER,TABLE_NAME,COLUMN_NAME,COMPRESSION,DEDUPLICATION,SECUREFILE from  dba_lobs where compression not in ('NONE','NO');
select TABLE_OWNER,TABLE_NAME,COLUMN_NAME,COMPRESSION,DEDUPLICATION,SECUREFILE from  dba_lob_partitions where compression not like ('NONE');
select DEST_NAME, COMPRESSION from v$archive_dest where compression not like ('DISABLE');
PROMPT DISABLE COMPRESION:
PROMPT 1. OLTP Table Compression -> _OLTP_COMPRESSION=false
PROMPT 2- LOB Compression ->  DB_SECUREFILE=NEVER
PROMPT 3- Data Pump Compression -> Bug 8478082: DISALLOW UNLICENSED COMPRESSION FEATURE WHILE USING DATA PUMP
PROMPT 4- Fast ZLIB RMAN Compression -> no need license: BZIP2 or BASIC
PROMPT 5- Data Guard Log Transport Compression -> DGMGRL> edit database 'DB_SITE1' set property RedoCompression='DISABLE'; ENABLE_OPTION_ADVANCED_COMPRESSION=FALSE
PROMPT ===================================== 4)Uso Licencias Backup
PROMPT
PROMPT CHECK RMAN: RMAN -> show all; exit; -> COMPRESS ZLIB
spool off

