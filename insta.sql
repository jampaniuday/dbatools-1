Set Termout  On
Set Timing off
Prompt

Ttitle  ' [ Oracle Instance Information ]'  skip 2
Set Heading  Off
Set Feedback Off
column status           format a120 wrap             heading "Status"

Select status_01||'    | '||status_02 status
  From
       (Select '   Host_Name     '||Lpad(Host_Name,18) status_02 from V$Instance)
     , (Select '   Cpu_Count             '||Lpad(value,8) status_01 from V$PARAMETER where name='cpu_count' and value is not null)
Union
Select status_01||'    | '||status_02 status
  From
       (Select '   Instance_Name     '||Lpad(Instance_Name,12) Status_01 from V$Instance)
     , (Select '   Database_Status     '||Lpad(Database_Status,12) Status_02 from V$Instance)
Union
Select status_01||'    | '||status_02 status
  From
       (Select '   Startup_Time    '||To_Char(Startup_Time, 'DD-MM-YYYY HH24:MI') Status_02 from V$Instance)
     , (Select '   Status            '||Lpad(Status,12) Status_01 from V$Instance)
Union
Select status_01||'    | '||status_02 status
  From
       (Select '   Version           '||Lpad(Version,12) Status_01 from V$Instance)
     , (Select '   Instance_Role   '||Lpad(Instance_Role,16) Status_02 from V$Instance)
Union
Select status_01||'    | '||status_02 status
  From
       (Select '   Instance Status   '||Lpad('OK',12) Status_01 from V$Instance)
     , (Select '   Listener Status   '||Lpad('OK',12) Status_02 from V$Instance)
;
Ttitle  Off
select '   Database log mode            '||log_mode "Parameter" from V$DATABASE
union
select '   Archive destination          '||value    from V$PARAMETER where (name='log_archive_dest' or name = 'log_archive_dest_1') and value is not null
;

select '   Spfile                       '||value    from V$PARAMETER where name='spfile' and value is not null
union
select '   Background Dump Dest         '||value    from V$PARAMETER where name='background_dump_dest' and value is not null
;
Ttitle  Off

prompt

Declare
  --
  Cursor Cur_Req Is
        Select distinct object_name
      from dba_objects
      where object_name='DBA_TEMP_FILES'
        ;
  --
   Cursor Cur_SGA Is
        select '   SGA (Mb)                '||Lpad(To_Char(Round(sum (value)/1024/1024)),8) status_02 from v$sga;
  --
  W_Texte       Varchar2(2000);
  Curs          Integer;
  Return_code   Integer;
  W_Temp        Varchar2(40);
  --
  X             Varchar2(100);
  Nb_Tf         Number(8);
  SGA           Varchar2(40);
  --
Begin
  --
  X := Null;
  --
  Open Cur_Req;
    Fetch Cur_Req Into X;
  Close Cur_Req;
  --
  Open Cur_SGA;
    Fetch Cur_SGA Into SGA;
  Close Cur_SGA;
  --
  If X Is Not Null Then
    --
    W_Texte :=  'Select ''Database Space (Mb)   ''||Lpad(To_Char(Round((nb_ctl.nb * ctl_size.the_size) ';
    W_Texte :=  W_texte ||' + (rlf_size.the_size/1024) ';
    W_Texte :=  W_texte ||' + (dtf_size.the_size/1024) ';
    W_Texte :=  W_texte ||' + (nvl(dtft_size.the_size,0)/1024))),8) From  ';
    W_Texte :=  W_texte ||' (select count(1) nb from v$controlfile) nb_ctl ';
    W_Texte :=  W_texte ||' , (select round(sum(record_size)/1024) the_size from V$CONTROLFILE_RECORD_SECTION) ctl_size ';
    W_Texte :=  W_texte ||' , (select round(sum(bytes)/1024) the_size from v$log) rlf_size ';
    W_Texte :=  W_texte ||' , (select round(sum(bytes)/1024) the_size from dba_data_files) dtf_size ';
    W_Texte :=  W_texte ||' , (select round(sum(bytes)/1024) the_size from dba_temp_files) dtft_size';
    --
  Else
    --
    W_Texte :=  'Select ''Database Space (Mb)   ''||Lpad(To_Char(Round((nb_ctl.nb * ctl_size.the_size) ';
    W_Texte :=  W_texte ||' + (rlf_size.the_size/1024) ';
    W_Texte :=  W_texte ||' + (dtf_size.the_size/1024) ';
    W_Texte :=  W_texte ||' + (nvl(dtft_size.the_size,0)/1024))),8) From  ';
    W_Texte :=  W_texte ||' (select count(1) nb from v$controlfile) nb_ctl ';
    W_Texte :=  W_texte ||' , (select round(sum(record_size)/1024) the_size from V$CONTROLFILE_RECORD_SECTION) ctl_size ';
    W_Texte :=  W_texte ||' , (select round(sum(bytes)/1024) the_size from v$log) rlf_size ';
    W_Texte :=  W_texte ||' , (select round(sum(bytes)/1024) the_size from dba_data_files) dtf_size ';
    --
  End If;
  --
  Curs := Dbms_Sql.Open_Cursor;
  --
  Dbms_Sql.Parse(Curs, W_texte, Dbms_Sql.Native);
  Dbms_Sql.Define_Column(Curs, 1, W_Temp, 40);
  --
  Return_Code := Dbms_Sql.Execute(Curs);
  --
  IF dbms_sql.FETCH_ROWS(Curs)>0 THEN
    Dbms_Sql.Column_Value(Curs, 1, W_Temp);
  End If;
  --
  Dbms_OutPut.Put_Line('-- '||W_Temp||'    | '||SGA||' --');
  --
  Dbms_Sql.Close_Cursor(Curs);
  --
End;
/


Declare
  --
  Cursor Cur_Req Is
        Select distinct object_name
      from dba_objects
      where object_name='DBA_TEMP_FILES'
        ;
  --
  Cursor Cur_Df Is
        Select Count(*)
      From dba_data_files
        ;
  --
  W_Texte               Varchar2(2000);
  Curs                  Integer;
  Return_code           Integer;
  W_Temp                Varchar2(20);
  --
  X     Varchar2(100);
  Nb_Tf         Number(8);
  Nb_Df         Number(8);
  --
Begin
  --
  X := Null;
  --
  Open Cur_Req;
    Fetch Cur_Req Into X;
  Close Cur_Req;
  --
  Open Cur_Df;
    Fetch Cur_Df Into Nb_Df;
  Close Cur_Df;
  --
  If X Is Not Null Then
    --
    W_Texte :=  'Select To_Char(Count(*)) From dba_temp_files';
    --
    Curs := Dbms_Sql.Open_Cursor;
    --
    Dbms_Sql.Parse(Curs, W_texte, Dbms_Sql.Native);
    Dbms_Sql.Define_Column(Curs, 1, W_Temp, 20);
    --
    Return_Code := Dbms_Sql.Execute(Curs);
    --
    IF dbms_sql.FETCH_ROWS(Curs)>0 THEN
      Dbms_Sql.Column_Value(Curs, 1, W_Temp);
    End If;
    --
    Dbms_OutPut.Put_Line('-- Nb. Datafiles            '||Lpad(To_Char(Nb_Df),5)||'    |    Nb. Tempfiles              '||Lpad(W_Temp,5)||' --' );
	Dbms_OutPut.Put_Line('----------------------------------------------------------------------------------------------------');
    --
    Dbms_Sql.Close_Cursor(Curs);
    --
  Else
    Dbms_OutPut.Put_Line('-- Nb. Datafiles            '||Lpad(To_Char(Nb_Df),5));
	Dbms_OutPut.Put_Line('----------------------------------------------------------------------------------------------------');
  End If;
  --
End;
/
Ttitle  Off
Set Timing on
Set heading on
Set Feedback On