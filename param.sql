

set wrap on
set long 60000
set verify off
set pagesize 9999
set lines 350

select name, ispdb_modifiable
from v$parameter
where name like ='%&1%'


