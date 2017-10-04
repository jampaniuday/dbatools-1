set lines 350 pages 350
col LAST_ANLZD format a25
col TAB_NAME format a35
select dbta.owner || '.' || dbta.table_name tab_name,
       dbta.num_rows anlyzd_rows,
       to_char(dbta.last_analyzed, 'yyyymmdd hh24:mi:ss') last_anlzd,
       nvl(dbta.num_rows, 0) + nvl(dtm.inserts, 0) - nvl(dtm.deletes, 0) tot_rows,
       nvl(dtm.inserts, 0) inserts,
       nvl(dtm.deletes, 0) deletes,
       nvl(dtm.updates, 0) updates,
       nvl(dtm.inserts, 0) + nvl(dtm.deletes, 0) + nvl(dtm.updates, 0) chngs,
       round((nvl(dtm.inserts, 0) + nvl(dtm.deletes, 0) + nvl(dtm.updates, 0)) /
       greatest(nvl(dbta.num_rows, 0), 1)*100,2) pct_c,
       dtm.truncated trn
  from dba_tables dbta
-- replace below with all_tab_modifications if you need
  left outer join sys.dba_tab_modifications dtm on dbta.owner =
                                                   dtm.table_owner
                                               and dbta.table_name =
                                                   dtm.table_name
                                               and dtm.partition_name is null
where dbta.table_name = '&&nombre_tabla'
   and dbta.owner = '&&owner_tabla'
/


exec DBMS_STATS.FLUSH_DATABASE_MONITORING_INFO;
