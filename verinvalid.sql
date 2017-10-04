
set echo off
set heading on

prompt
prompt  .: Listado objetos invalidos
prompt


SELECT 
 'alter '||decode(object_type,'PACKAGE BODY','PACKAGE',object_type) ||' '||owner||
  '."'||object_name||'" '||decode(object_type,'PACKAGE BODY','COMPILE BODY','COMPILE')||';' 
 FROM all_objects 
 WHERE owner like '%'
 AND owner not in ('SYS', 'SYSTEM')
 AND object_type IN 
 ('PACKAGE','PACKAGE BODY','VIEW','PROCEDURE','TRIGGER','FUNCTION') 
 AND status='INVALID';	

prompt
prompt  .: Resumen objetos invalidos
prompt
-- Número de objetos inválidos:
SELECT owner, count(*) FROM DBA_OBJECTS WHERE STATUS='INVALID'
group by owner;

SELECT NVL(COUNT(*),0) "TOTAL"
  FROM DBA_OBJECTS
WHERE STATUS = 'INVALID' 
  AND OBJECT_TYPE <> 'SYNONYM';


prompt
prompt .: Listado indices invalidos
prompt

select 'alter index '||owner||'.'||index_name||' rebuild tablespace '|| TABLESPACE_NAME||';'
from dba_indexes where status = 'UNUSABLE';


select table_owner,index_name,status
from dba_INDEXES
where status <> 'VALID';

set echo on
