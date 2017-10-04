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
Rem =============================================  .: dbatools ==== sgc ===
Rem = [ACTIVIDAD SESIONES] ================================================
Rem ==	@bdperf ------- Vision general:  wevents, sessions, Top,etc...
Rem ==	@ses ---------- wait events + active sessions + sqls
Rem ==	@pxses -------- paralel execution info
Rem ==	@vercur ------- Explain plan de sql en ejecucion. cursor.
Rem ==	@stats -------- Session stats by a specific SID
Rem ==	@versql ------- Un sql concreto por id.
Rem ==	@useract ------ actividad de usuarios.
Rem ==	@verun -------- procesos/sesiones corriendo activas.
Rem ==	@versqls ------ Todas las sql en ejecucion
Rem ==	@cursores ----- Que cursores usa un usuario.
Rem ==	@longo -------- long running operations.
Rem = [TROUBLESHOTING] ====================================================
Rem ==	@verwait ------ Esperas.
Rem ==	@alert -------- revision alertas bd, alertlog
Rem ==	@locks -------- bloqueos y como sentencia de resolucion.
Rem ==	@topsql ------- top SQL % y lista de SQL.
Rem ==	@racdiag ------ troubleshoot RAC.
Rem ==	@sqltune ------ Sql tuning advisor findings and recomend.
Rem ==	@checkdb ------ General Health status of database
Rem = [BD INFO] ============================================================
Rem ==  @infodb ------- info para recrear bd
Rem ==	@tbsp --------- ocupacion de tablespaces y asm
Rem ==	@verhwm ------- espacio disoponible de datafile con/sin HWM
Rem ==	@verbackups --- informacion sobre backups y export en curso
Rem ==	@verjobs ------ Jobs corriendo y lista todos
Rem ==	@verasm ------- Ver info de asm: disco,ficheros,grupos
Rem ==	@asmfiles ----- Info. Ficheros de ASM
Rem ==	@verbd -------- all database sessions are currently doing wait/CPU usag.
Rem ==	@vertab ------- Informacion detallada tabla.
Rem ==	@veridx ------- Informacion detallada indice.
Rem ==	@vertemp ------ Informacion y uso del Temporal.
Rem ==	@verundo ------ informacion sobre el undo
Rem ==	@verinvalid --- Indices y objetos invalidos
Rem ==	@redogen ------ redo info.
Rem ==	@vercursores -- Uso de cursores. todos los usuarios
Rem ==	@oralic ------- Check uso caracteristicas con licencia de ORACLE
Rem ==	@vertam ------- multiple sizes of database: bd,ts,
Rem ==	@tams --------- size of schema
Rem ==	@tamt --------- size of a table
Rem ==	@tambd -------- Size of all extends
Rem ==	@dg ----------- Checks to dataguard
Rem = [ACTIVIDAD CPU/IO] ====================================================
Rem ==	@topcpu ------- top CPU and Top SQL CPU activity% using SQL
Rem ==	@sqlrt  ------- Top SQL Response TIME last 2h and 
Rem ==	@tps  --------- TPS (Transactions/s) from snaps
Rem ==	@filestat ----- Report v$filestat, reporta I/O de los discos.
Rem ==  @verio -------- physical IO: redo size, physical reads and physical writes
Rem ==	@verlecturas -- top Sesiones Lecturas Fisicas/Logicas 
Rem = [INSTANCIA / MEMORIA] =================================================
Rem ==  @vermem  ------- memoria info.
Rem ==	@pga ---------- PGA info
Rem ==	@ratios ------- % ratios de uso de instancia.
Rem ==	@sqlarea ------ dump a SQL library -> cache en /tmp/sqlarea.&m_timestamp
Rem ==	@versorts ----- sorts memoria/disco, media de sorts,etc...
Rem == [STANDBY / DATAGUARD] ================================================
Rem ==	@stdby -------- status managed standby
Rem ========================================================================
set echo off

Set Heading  on
set timing on



