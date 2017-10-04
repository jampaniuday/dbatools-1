REM -- tablas a compactar?
set lin 450 pages 900

select * from (
select owner,tablespace_name, table_name, NUM_ROWS,(blocks*8/1024)+ROUND((AVG_ROW_LEN * NUM_ROWS / (1024 * 1024)), 2) TOTAL, blocks*8/1024 Reserved_MB,  ROUND((AVG_ROW_LEN * NUM_ROWS / (1024 * 1024)), 2) Consumed_MB,
((blocks*8/1024)*100)/((blocks*8/1024)+ROUND((AVG_ROW_LEN * NUM_ROWS / (1024 * 1024)), 2)) RESERV
from all_tables 
where NUM_ROWS > 1
and owner not in ('SYSMAN','SYSTEM','WMSYS','SYS','PERFSTAT','SCOTT','XDB','ORDDATA','ORDDATA','ORDDATA','APEX_030200','CTXSYS','DBSNMP','EXFSYS','MDSYS','OLAPSYS','ORDSYS') 
) where  Consumed_MB > 0 and RESERV > 80 OR (RESERV > 60 and NUM_ROWS > 1000000 )
order by 1,2,4,6 desc;


REM -- Que se puede reducir ? - watermark - compactacion

set verify off
column file_name format a50 word_wrapped
column smallest format 999,990 heading "Smallest|Size|Poss."
column currsize format 999,990 heading "Current|Size"
column savings  format 999,990 heading "Poss.|Savings"
break on report
compute sum of savings on report

column value new_val blksize
select value from v$parameter where name = 'db_block_size'
/

select a.file_id, file_name,
       ceil( (nvl(hwm,1)*&&blksize)/1024/1024 ) smallest,
       ceil( blocks*&&blksize/1024/1024) currsize,
       ceil( blocks*&&blksize/1024/1024) -
       ceil( (nvl(hwm,1)*&&blksize)/1024/1024 ) savings
from dba_data_files a,
     ( select file_id, max(block_id+blocks-1) hwm
         from dba_extents
        group by file_id ) b
where a.file_id = b.file_id(+)
/

column cmd format a75 word_wrapped

select 'alter database datafile ''' || file_name || ''' resize ' ||
       ceil( (nvl(hwm,1)*&&blksize)/1024/1024 )  || 'm;' cmd
from dba_data_files a,
     ( select file_id, max(block_id+blocks-1) hwm
         from dba_extents
        group by file_id ) b
where a.file_id = b.file_id(+)
  and ceil( blocks*&&blksize/1024/1024) -
      ceil( (nvl(hwm,1)*&&blksize)/1024/1024 ) > 0
/ 