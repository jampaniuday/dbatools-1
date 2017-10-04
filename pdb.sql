
select PDB_NAME,con_id  from cdb_pdbs;

declare
  pdb VARCHAR2(30);
begin
  select PDB_NAME into pdb from cdb_pdbs where con_id=&1;
  execute immediate 'alter session set container='||pdb;
end;
/
show con_name