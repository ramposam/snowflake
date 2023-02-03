CREATE OR REPLACE PROCEDURE GENERATE_DML_STATEMENTS(TABLE_NAME VARCHAR,SCHEMA_NAME VARCHAR default 'EDP_SDM',DATABASE_NAME VARCHAR DEFAULT 'EDP_SDM_DB')
returns string 
language SQL
as
DECLARE
--DATABASE_name varchar(200):='EDP_SDM_DB';
--schema_name varchar(200):='EDP_SDM';
--table_name varchar(200):='T_ESG_GEN_REF_SANCTION_VIOLATIONS';
from_clause varchar(2000):=' FROM '||DATABASE_name||'.'||schema_name||'.'||table_name;
data_query varchar(32000);
select_clause varchar(32000):='select OBJECT_CONSTRUCT_KEEP_NULL';
query_result resultset;
metadata_cols_query varchar(32000):='SELECT LISTAGG (COLUMN_NAME,'','') WITHIN GROUP (ORDER BY ORDINAL_POSITION) as cols_str FROM (
	SELECT COLUMN_NAME,ORDINAL_POSITION  FROM INFORMATION_SCHEMA.COLUMNS
	WHERE TABLE_NAME = '''||table_name||'''
	AND COLUMN_NAME  NOT IN 
	(''CREATED_BY_USER_ID'',
	''UPDATED_DTS'',
	''UPDATED_BY_USER_ID'',
	''CREATED_DTS'',
	''ROW_HASH_ID'') )';
metadata_cols_query_2 varchar(32000):='SELECT COLUMN_NAME  FROM INFORMATION_SCHEMA.COLUMNS
	WHERE TABLE_NAME = '''||table_name||'''
	AND COLUMN_NAME  NOT IN 
	(''CREATED_BY_USER_ID'',
	''UPDATED_DTS'',
	''UPDATED_BY_USER_ID'',
	''CREATED_DTS'',
	''ROW_HASH_ID'') order by ORDINAL_POSITION';
col_string varchar(2000);
insert_cols varchar(2000);
column_result varchar(2000);
col_string_array ARRAY;
col_values varchar(32000):='';
col_string_array_size number(10);
col_value varchar(200);
insert_stmt varchar(16777216);
BEGIN

query_result :=(EXECUTE IMMEDIATE metadata_cols_query);
FOR result IN query_result loop
	col_string := result.cols_str;
end loop;
query_result :=(EXECUTE IMMEDIATE metadata_cols_query_2);

FOR table_col IN query_result loop
	insert_cols := ifnull(insert_cols,'')||''''||table_col.COLUMN_NAME||''','||table_col.COLUMN_NAME||',';	
end loop;

data_query := select_clause||'('||trim(insert_cols,',')||')  as out_column '||from_clause;
query_result := (EXECUTE IMMEDIATE data_query);
col_string_array:=split(col_string, ','); 	
col_string_array_size := ARRAY_SIZE(col_string_array)-1;
FOR result in query_result loop 
	column_result:=NULL;
 	FOR i  IN 0 TO col_string_array_size loop
	col_value:=''''||RESULT.out_column[col_string_array[i]::STRING]||'''';	
	column_result := ifnull(column_result,'')||ifnull(col_value,'NULL') ||',' ;

	END loop;
	col_values:='insert into '||DATABASE_name||'.'||schema_name||'.'||table_name||'('||col_string||',CREATED_DTS,CREATED_BY_USER_ID) values ('||column_result||' current_timestamp(0),current_user);';
	insert_stmt:=ifnull(insert_stmt,'')||chr(13)||col_values;

END loop;
  RETURN insert_stmt;
END;
