SELECT
RPAD('(' || p.ID || ' ' || NVL(p.parent_id,'0') || ')',8) || '|' ||
RPAD(LPAD (' ', 2*p.DEPTH) || p.operation || ' ' || p.options,40,'.') ||
NVL2(p.object_owner||p.object_name, '(' || p.object_owner|| '.' || p.object_name || ') ', '') ||
'Cost:' || p.COST || ' ' || NVL2(p.bytes||p.CARDINALITY,'(' || p.bytes || ' bytes, ' || p.CARDINALITY || ' rows)','') || ' ' ||
NVL2(p.partition_id || p.partition_start || p.partition_stop,'PId:' || p.partition_id || ' PStart:' ||
p.partition_start || ' PStop:' || p.partition_stop,'') ||
'io cost=' || p.io_cost || ',cpu_cost=' || p.cpu_cost AS PLAN
FROM dba_hist_sql_plan p
WHERE p.sql_id='&sql_id'
AND plan_hash_value='&plan_hash_value'
ORDER BY p.id, p.parent_id;