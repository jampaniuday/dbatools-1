SELECT * FROM table(DBMS_XPLAN.DISPLAY_CURSOR(('&1'),0));

set echo off

select 
        child_number    sql_child_number,
        address         parent_handle,
        child_address   object_handle,
        plan_hash_value plan_hash,
        parse_calls parses,
        loads h_parses,
        executions,
        fetches,
        rows_processed,
  rows_processed/nullif(fetches,0) rows_per_fetch,
        cpu_time/10001000 cpu_sec,
        elapsed_time/1000000 ela_sec,
        buffer_gets LIOS,
        disk_reads PIOS,
        sorts
--      address,
--      sharable_mem,
--      persistent_mem,
--      runtime_mem,
--   , PHYSICAL_READ_REQUESTS         
--   , PHYSICAL_READ_BYTES            
--   , PHYSICAL_WRITE_REQUESTS        
--   , PHYSICAL_WRITE_BYTES           
--   , IO_CELL_OFFLOAD_ELIGIBLE_BYTES 
--   , IO_INTERCONNECT_BYTES          
--   , IO_CELL_UNCOMPRESSED_BYTES     
--   , IO_CELL_OFFLOAD_RETURNED_BYTES 
  ,     users_executing
from 
        v$sql
where 
        sql_id = ('&1')
order by
        sql_id,
        hash_value,
        child_number
/


SELECT child_number, disk_reads, buffer_gets, user_io_wait_time, optimizer_mode, optimizer_cost, plan_hash_value, cpu_time, elapsed_time
FROM v$sql WHERE sql_id='&1'
ORDER BY child_number;

SET pages 50
col begin_interval_time FOR a30
col sql_profile FOR a30
SET lines 200
col cpu_time_total FOR 9999999999999999
col elapsed_time_total FOR 9999999999999999
col iowait_total FOR 9999999999999999
SELECT b.begin_interval_time, a.plan_hash_value, a.optimizer_mode, a.sql_profile, a.disk_reads_total, a.buffer_gets_total, a.cpu_time_total, a.elapsed_time_total, a.iowait_total
FROM dba_hist_sqlstat a, dba_hist_snapshot b
WHERE sql_id='&1'
AND a.snap_id=b.snap_id
AND b.begin_interval_time > SYSDATE -2
ORDER BY a.snap_id DESC;



set echo on