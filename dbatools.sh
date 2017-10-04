#!/usr/bin/ksh
#   dbatools.sh 
# Script que chequea una maquina y de forma unificada
#
# usage: dbatools [nombre_instancia]
#

. $HOME/.profile >/dev/null

export ORACLE_SID=$1
scriptDir='$ORACLE_HOME/scripts/dbatools/

FECHA=`date '+%Y%m%d'`
DIA=`date '+%d'`
MES=`date '+%m'`


while true
do

clear
echo " \n\n"
echo "                .: DBATOOLs "
echo "               ------------------"
echo "\n\n\n"
echo "\n        1.-    Waits           "
echo "\n        2.-    Hit Ratios      "
echo "\n        3.-    User Actividad  "
echo "\n        4.-    Ver SQL         "
echo "\n        5.-    Ver Memoria     "
echo "\n        6.-    Ver Redo        "
echo "\n        6.-    Ver BD esperas  "
echo "\n        6.-    TVer Cursores   "
echo "\n        6.-    tablespaces     "
echo "\n        6.-    Top CPU         "
echo "\n        6.-    Top CPU         "
echo "\n        7.-    LOG BACKUP DATA PROTECTOR"
echo "\n\n\n        0.-    SALIR "
echo "\n\n\n"

echo "Elija una opcion: "
read opc1

     case ${opc1} in
       Z|z)
           clear
           $ORACLE_HOME/bin/sqlplus -s "/ as sysdba" @d_exp @$scriptDir/
           echo "Pulsa RETORNO para continuar"
           read sigue
       ;;
       A|a)
           clear
           $BIN/MenuOracle
       ;;
       B|b)
           clear
           $BIN/MenuMaxDB
       ;;
       C|c)
           clear
           $BIN/EstudioSDE
           echo "Pulsa RETORNO para continuar"
           read sigue
       ;;
       D|d)
           clear
           ##
           ## Para que esta opcion muestre informacioni, TODOS los dias se debe ejecutar el script:
           ## $BIN/EstudioTBL (actualmente se ejecuta en el crontab del usuario sbdadmin de sgcdev )
           ##
           $ORACLE_HOME/bin/sqlplus admma/$PASO@d_exp @$BIN/PLSQL/ComparaTBL.sql
           echo "Pulsa RETORNO para continuar"
           read sigue
       ;;
       E|e)
           clear
           ##
           ## Para que esta opcion muestre informacioni, TODOS los dias se debe ejecutar el script:
           ## /oracle/920_64/adminbin/EstudioFS (actualmente se ejecuta a mano)
           ## Se ejecuata para TODAS las instancias ORACLE o MaxDB
           ##
           $ORACLE_HOME/bin/sqlplus admma/$PASO@d_exp @$BIN/PLSQL/ComparaFS.sql
           echo "Pulsa RETORNO para continuar"
           read sigue
       ;;
       F|f)
           clear
           $ORACLE_HOME/bin/sqlplus admma/$PASO@d_exp @$BIN/PLSQL/viewBackupLog.sql
       ;;
       0)
           exit
       ;;
       *)
           continue
       ;;
     esac

done 