CREATE OR REPLACE PROCEDURE generate_dmls(tables_list ARRAY,schema_name varchar,database_name varchar)
returns string 
language SQL
as
DECLARE

ln_array_size 		number(10);
query 				varchar(32000);
--database_name 	varchar(200):='EDP_SDM_DB';
--schema_name 	varchar(200):='EDP_SDM';
object_type 	varchar(200):='TABLE';
dml_query 		varchar(16777216);
query_result 	resultset;
BEGIN
	ln_array_size:=array_size(tables_list);
	
   FOR i IN 0 TO ln_array_size-1 loop
	  query:='call GENERATE_DML_STATEMENTS('''||tables_list[i]::STRING||''','''||schema_name||''','''||database_name||''' ) ' ;
   	  query_result:=(EXECUTE IMMEDIATE query);
   	  FOR res IN (query_result) loop
   	  	dml_query:=ifnull(dml_query,'')||chr(13)||IFNULL(res.GENERATE_DML_STATEMENTS,'');
   	  end loop;
   	  
   end loop;
   
	RETURN dml_query;
END;

