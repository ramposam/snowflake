CREATE OR REPLACE PROCEDURE generate_ddls(tables_list ARRAY,schema_name varchar,database_name varchar)
returns string 
language SQL
as
DECLARE

ln_array_size 		number(10);
query 				varchar(32000);
--database_name 	varchar(200):='EDP_SDM_DB';
--schema_name 	varchar(200):='EDP_SDM';
object_type 	varchar(200):='TABLE';
ddl_query 		varchar(16777216);
query_result 	resultset;
BEGIN
	ln_array_size:=array_size(tables_list);
	
   FOR i IN 0 TO ln_array_size-1 loop
	   query:='select get_ddl('''||object_type||''','''||database_name||'.'||schema_name||'.'|| tables_list[i]::STRING||''' ) as script ' ;
   	  query_result:=(EXECUTE IMMEDIATE query);
   	  FOR res IN query_result loop
   	  	ddl_query:=ifnull(ddl_query,'')||chr(13)||res.script;
   	  end loop;
   	  
   end loop;
   
	RETURN ddl_query;
END;
