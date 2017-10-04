--tambd


Ttitle  ' [ tamaño bd total ]'  skip 1
-- tamaño bd total

select sum(BYTES)/1024/1024 MB from DBA_EXTENTS;