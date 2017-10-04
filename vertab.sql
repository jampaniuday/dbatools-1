set pagesize 5000
set linesize 350
set echo off
col table_name for a25
col SEGMENT_NAME for a25

alter session set nls_date_format = 'dd-mm-yyyy hh24:mi:ss';

-- define owner and table name
define own = &1
define tab = &2


Ttitle  ' [ INDEXES ]'  skip 1
select index_name,INDEX_TYPE, PARTITIONED ,TABLE_TYPE
from dba_indexes WHERE table_name = '&tab';

Ttitle  ' [ TABLE y INDEXES CREATE ]'  skip 1

SELECT DBMS_METADATA.get_ddl ('TABLE','&tab','&own') FROM   dual;
SELECT DBMS_METADATA.GET_DEPENDENT_DDL('INDEX','&tab','&own') from dual;

colu num_rows form 99999,999,999
Ttitle  ' [ Espacio Reservado ]'  skip 1
select table_name, NUM_ROWS,(blocks*8/1024)+ROUND((AVG_ROW_LEN * NUM_ROWS / (1024 * 1024)), 2) TOTAL, blocks*8/1024 Reserved_MB,  ROUND((AVG_ROW_LEN * NUM_ROWS / (1024 * 1024)), 2) Consumed_MB,
((blocks*8/1024)*100)/((blocks*8/1024)+ROUND((AVG_ROW_LEN * NUM_ROWS / (1024 * 1024)), 2)) RESERV
from all_tables 
where table_name like '&tab' 
and NUM_ROWS > 1
order by 4,6 desc;

Ttitle  ' [ COLUMNAS ]'  skip 1
select column_name,DATA_TYPE from dba_tab_columns where table_name = '&tab' 
and owner = '&own' order by column_id;


Ttitle	  ' [ Tamaño Tabla+Indices ]'  skip 1
select sum(bytes)/1024/1024 Table_Allocation_MB 
from dba_segments
where segment_type in ('TABLE','INDEX') and
(segment_name='&tab' or segment_name in 
(select index_name from dba_indexes where table_name='&tab'));



Ttitle  ' [ Tamaño Tabla ]'  skip 1
select SEGMENT_NAME, bytes/1024/1024 Table_Allocation_MB 
from dba_segments
where SEGMENT_NAME like '&tab'
and owner = '&own';

Ttitle  ' [ INFO ]'  skip 1
select OBJECT_NAME,OWNER,OBJECT_TYPE  ,CREATED,LAST_DDL_TIME,STATUS  from dba_objects where object_name like '%&tab%'
and owner = '&own';
