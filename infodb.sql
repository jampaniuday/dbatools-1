set echo off
set feedback off
set timing off
--set termout off
set trimspool on 
set verify off

set linesize 180
set pagesize 5000

Select name Nombre_BD from v$database;
select instance_name Nombre_Instancia from v$instance;



prompt
prompt [ FICHEROS ]
prompt 

select * from v$instance;
select dbid,name from v$database;
SELECT Substr(name,1,60) datafile,
NVL(status,'UNKNOWN') estado, enabled activo, LPad(To_Char(Round(bytes/1024000,2),'9999990.00'),10,' ') Tamanio FROM v$datafile 
ORDER BY 1;
select name from v$controlfile;
select member from v$logfile;
select name from v$tempfile;


--! echo Oracle_Home = $ORACLE_HOME

prompt
prompt [ VERSION DE ORACLE - x$version]
prompt 
select * from x$version;

prompt
prompt [ VERSION DEL SISTEMA OPERATIVO ]
prompt 

! uname -a

prompt
prompt [ OBTENER LOS PARAMETROS DE INIT<SID>.ORA - v$parameter ]
prompt 

set linesize 180
col name format a80
col value format a80

select distinct name, value
from v$parameter
where isdefault='FALSE';
prompt
prompt [ OBTENER IDIOMA Y JUEGO DE CARACTERES DE LA BBDD - nls_database_parameters ]
prompt


select * from nls_database_parameters;

prompt
prompt [ OBTENER CONFIGURACION DE LOS REDO LOGS - v$logfile,v$log ]
PROMPT 

col Grupo   format 999
col Miembro format a60
col Bytes   format 9999999999
col Estado  format a10

select distinct a.group# Grupo, a.member Miembro, b.bytes Bytes, b.status Estado
from v$logfile a, v$log b
where a.group# = b.group#;

prompt
prompt [ CONFIGURACION DE LOS FICHEROS DE CONTROL - v$controlfile ]
prompt 

select * from v$controlfile;

prompt
prompt [ CREACION DE LOS TABLESPACES - dba_tablespaces, dba_data_files ]
prompt 

col TBS format a16
col Filename format a42
col Init format 999999999
col Next format 999999999
col MinExt format 999999999
col MaxExt format 99999999999
col PctInc format 99
col Stat format a6
col autoextensible format a5
col MB format 9999

select a.tablespace_name TBS, b.file_name FileName, a.initial_extent Init, a.next_extent Next, a.min_extents MinExt, a.max_extents MaxExt, a.pct_increase PctInc, a.status Stat, b.autoextensible,b.bytes/1024/1024 MB from dba_tablespaces a, dba_data_files b where a.tablespace_name = b.tablespace_name order by a.tablespace_name;

select 'create tablespace '||a.tablespace_name||' datafile '''||b.file_name||''''||' size '||b.bytes/1024/1024||'M'||' default stora
ge ('||'initial '||a.initial_extent||' next '||a.next_extent||' minextents '||a.min_extents||' maxextents '||a.max_extents||' pctinc
rease '||a.pct_increase||');' Crear_Tablespaces
from dba_tablespaces a, dba_data_files b
where a.tablespace_name  = b.tablespace_name
order by a.tablespace_name;

prompt
prompt [ CREACION DE LOS SEGMENTOS DE ROLLBACK - dba_rollback_segs ]
prompt 

col Segmento format a15
col Tablespace format a15
col Inicial format 999999999
col Next format 999999999
col MinExtent format 999999999
col MaxExtent format 999999999
col PctInc format 999

--select segment_name Segmento, tablespace_name Tablespace, initial_extent Inicial, next_extent Next, min_extents MinExtent, max_extents MaxExtent,pct_increase PctInc from dba_rollback_segs;

--select 'create rollback segment '||segment_name||' tablespace '||tablespace_name||' storage ('||'initial '||initial_extent|| ' next '||next_extent||' minextents '||min_extents||' maxextents '||max_extents||');' Crear_Segmentos_Rollback from dba_rollback_segs where segment_name!='SYSTEM';

--select 'alter rollback segment '||segment_name||' online;' Poner_ONline_Segmentos
from dba_rollback_segs
where segment_name!='SYSTEM';

set feedback on
set timing on
set head on
--set termout off
set trimspool off 
set verify on
set echo on
