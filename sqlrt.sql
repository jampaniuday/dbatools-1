prompt
prompt  Top SQL Response TIME 2h -- gv$metric
prompt

select to_char(MAX(VALUE),  'FM99999999999999.9999') retvalue FROM GV$METRIC where   
METRIC_NAME in ('SQL Service Response Time') AND GROUP_ID=2 ORDER BY 1;

select inst_id,
TO_CHAR (begin_time, 'YYYYMMDDHH24') || CASE
    WHEN  TO_CHAR (begin_time, 'MI') >= '55'  THEN  '55'
    WHEN  TO_CHAR (begin_time, 'MI') >= '50'  THEN  '50'
    WHEN  TO_CHAR (begin_time, 'MI') >= '45'  THEN  '45'
    WHEN  TO_CHAR (begin_time, 'MI') >= '40'  THEN  '40'
    WHEN  TO_CHAR (begin_time, 'MI') >= '35'  THEN  '35'
    WHEN  TO_CHAR (begin_time, 'MI') >= '30'  THEN  '30'
    WHEN  TO_CHAR (begin_time, 'MI') >= '25'  THEN  '25'
    WHEN  TO_CHAR (begin_time, 'MI') >= '20'  THEN  '20'
    WHEN  TO_CHAR (begin_time, 'MI') >= '15'  THEN  '15'
    WHEN  TO_CHAR (begin_time, 'MI') >= '10'  THEN  '10'
    WHEN  TO_CHAR (begin_time, 'MI') >= '5'  THEN  '05'
                 ELSE  '00'
         END sample
,round((sum(value)/count(*)/100)*1000,00) SQL_msecs from gV$SYSMETRIC_HISTORY
where METRIC_NAME in ('SQL Service Response Time')
AND GROUP_ID=2
group by inst_id,
          TO_CHAR (begin_time, 'YYYYMMDDHH24') || CASE
    WHEN  TO_CHAR (begin_time, 'MI') >= '55'  THEN  '55'
    WHEN  TO_CHAR (begin_time, 'MI') >= '50'  THEN  '50'
    WHEN  TO_CHAR (begin_time, 'MI') >= '45'  THEN  '45'
    WHEN  TO_CHAR (begin_time, 'MI') >= '40'  THEN  '40'
    WHEN  TO_CHAR (begin_time, 'MI') >= '35'  THEN  '35'
    WHEN  TO_CHAR (begin_time, 'MI') >= '30'  THEN  '30'
    WHEN  TO_CHAR (begin_time, 'MI') >= '25'  THEN  '25'
    WHEN  TO_CHAR (begin_time, 'MI') >= '20'  THEN  '20'
    WHEN  TO_CHAR (begin_time, 'MI') >= '15'  THEN  '15'
    WHEN  TO_CHAR (begin_time, 'MI') >= '10'  THEN  '10'
    WHEN  TO_CHAR (begin_time, 'MI') >= '5'  THEN  '05'
                                                ELSE  '00'
         END
ORDER BY 2 desc;



