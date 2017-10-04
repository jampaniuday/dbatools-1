Set echo off
set timing off

Set Linesize 200
Set Pagesize 45
Set Desc Linenum On

Set Arraysize 1
Set Long 2000
Set Serveroutput On size 800000 ;

Set Heading  Off
Set Feedback Off
Set Verify   Off

Set Termout  On

set echo on
Rem ================================================== dbatools ===========
Rem == @alert -------- revision alertas bd, alertlog.
Rem == @bdperf ------- Vision general:  wevents, sessions, Top,etc...
Rem == @cursores ----- Que cursores usa un usuario.
Rem == @filestat ----- Report v$filestat, reporta I/O de los discos.
Rem == @infodb ------- info para recrear bd
Rem == @locks -------- bloqueos y como sentencia de resolucion.
Rem == @longo -------- long running operations.
Rem == @ratios ------- % ratios de uso de instancia.
Rem == @racdiag ------ troubleshoot RAC.
Rem == @racses ------- wait events + active sessions + sqls
Rem == @redogen ------ redo info.
Rem == @sqlarea ------ vuelca SQL de library cache en /tmp/sqlarea.&m_timestamp
Rem == @tbsp --------- ocupacion de tablespaces y asm
Rem == @topcpu ------- top CPU.
Rem == @topsql ------- top SQL % y lista de SQL.
Rem == @useract ------ actividad de usuarios.
Rem == @verasm ------- Ver info de asm: disco,ficheros,grupos
Rem == @verbd -------- all database sessions are currently doing wait/CPU usag.
Rem == @vercursores -- Uso de cursores. todos los usuarios
Rem == @vercur ------- Explain plan de sql en ejecucion. cursor.
Rem == @vertab ------- Informacion detallada tabla.
Rem == @vertemp ------ Informacion y uso del Temporal.
Rem == @vermem ------- memoria info.
Rem == @versql ------- Un sql concreto por id.
Rem == @versqls ------ Todas las sql en ejecucion
Rem == @versorts ----- sorts memoria/disco, media de sorts,etc...
Rem == @verlecturas -- top Sesiones Lecturas Fisicas/Logicas 
Rem == @verinvalid --- Indices y objetos invalidos
Rem == @verwait ------ Esperas.
Rem == @verjobs------- Jobs corriendo y lista todos
Rem == @verun -------- procesos/sesiones corriendo activas.
Rem == @verundo------- informacion sobre el undo
Rem == @verbackups ---- informacion sobre backups en curso
Rem =======================================================================
set echo off

Set Heading  on
set timing on



