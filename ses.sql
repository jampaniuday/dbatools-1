col sid format 999999
col sidserial format a15
col ses.sid||','||ses.serial# format a12
col machine format a15
col event format a15
col wait_class format a12            
col HORA_LOGIN format a20
col client_identifier format a10
col hora_ini format a10
col H_LOGON format a10
col texto format a30
col status format a1
col ET format 999999
col ss_wait format 999999
col program format a17
col osuser format a12
col ospid format a8
col process format a8
col I format 9
col username format a15
col module format a15
col srv format a10
--select 'alter system kill session '''||ses.sid||','||ses.serial#||',@'||ses.inst_id||''' immediate;'
select ses.sid||','||ses.serial#||',@'||ses.inst_id as sidserial,
   ses.inst_id I,
   p.spid ospid, -- Esta SI
   ses.process,  -- Esta SI
   ses.username,
                ses.machine,  -- Esta SI
   ses.program, -- Esta SI
   ses.osuser,
--   ses.client_identifier, -- Esta SI
--   ses.module,
   ses.wait_class,
   ses.event,
   substr(ses.status,0,1) status, -- Esta SI
   to_char(sysdate-(ses.last_call_et/24/60/60),'YYYY/MM/DD HH24:MI:SS') as hora_ini,
   seconds_in_wait as ss_wait,
   last_call_et ET,
   to_char(logon_time,'YYYY/MM/DD HH24:MI:SS') H_LOGON,
--       substr((select sql_text from gv$sql vsql where vsql.sql_id=ses.sql_id and vsql.inst_id = ses.inst_id and vsql.child_number = ses.sql_child_number and rownum = 1),0,150) texto, -- ESTA SI
substr(sq.sql_text,0,150) texto, --ESTA SI
service_name as srv, -- Esta SI
ses.sql_id
from gv$session ses 
left outer join gv$sql sq on (ses.sql_id = sq.sql_id and sq.inst_id = ses.inst_id and sq.child_number = ses.sql_child_number and rownum=1) -- ESTA SI
--  left outer join gv$process p on (p.addr = ses.paddr and p.inst_id = ses.inst_id)
,gv$process p
where p.addr = ses.paddr
and p.inst_id = ses.inst_id
--and ses.type <> 'BACKGROUND' -- Esta SI
--and ses.sid||','||ses.serial#||',@'||ses.inst_id = '110,39813,@2'
--and p.spid = '24791'
--and (ses.status <> 'INACTIVE'
--or ses.WAIT_CLASS <> 'Idle') -- Esta SI
--and ses.username like '%REPCIBELES%'
--and ses.sid  in (629)
and (ses.WAIT_CLASS <> 'Idle' -- Esta SI
-- or ses.PROGRAM like '%(J%'
-- or ses.PROGRAM like '%(P%'
-- or ses.PROGRAM like '%(DW%'
or ses.STATUS='KILLED') -- Esta SI
--and ses.client_identifier like '%26f'
--and ses.sid in ('954')
--and p.spid = 13973
--and ses.sql_id = 'fc317sy20zy48'
--and ses.program like 'rman%'
order by last_call_et;
