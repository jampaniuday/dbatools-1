--tams
undefine own

define own=&1

Ttitle  ' [ tamaño total ]'  skip 
SELECT  SUM(BYTES)/1024/1024 MB FROM DBA_EXTENTS
where owner = '&own';

Ttitle  ' [ Objetos de esquema ]'  skip 
select obj.object_type "Type", obj_cnt "Objects",
decode(seg_size, NULL, 0, seg_size) "size MB"
from ( select object_type, count(*) obj_cnt from dba_objects where owner='&own' group by object_type ) obj,
( select SEGMENT_TYPE, ceil(sum(bytes)/1024/1024) seg_size from dba_segments where owner='&own' group by SEGMENT_TYPE ) segment
where obj.object_type = segment.SEGMENT_TYPE(+)
order by 3 desc, 2 desc, 1;

Ttitle  ' [ top 10 tablas ]'  skip 
select SEGMENT_NAME, sum(bytes)/1024/1024 Table_Allocation_MB 
from dba_segments
where segment_type in ('TABLE','INDEX')
and owner = '&own'
and rownum < 10 group by segment_name
order by 2 DESC;



