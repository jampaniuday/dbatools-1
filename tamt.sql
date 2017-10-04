--tamt


SELECT segment_name, 
to_char ( sum(bytes)/1024/1024 , '999,999.90') as MB
from dba_extents where segment_type='TABLE'
and SEGMENT_NAME  like '&nom_tabla'   
group by segment_name,owner order by 2 DESC;