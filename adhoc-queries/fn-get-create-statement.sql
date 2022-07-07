CREATE OR REPLACE FUNCTION dune_user_generated.show_create_table(table_name text, join_char text = E'\n' ) 
  RETURNS text AS 
$BODY$
SELECT 'CREATE TABLE ' || $1 || ' (' || $2 || '' || 
    string_agg(column_list.column_expr, ', ' || $2 || '') || 
    '' || $2 || ');'
FROM (
  SELECT '    ' || column_name || ' ' || data_type || 
       coalesce('(' || character_maximum_length || ')', '') || 
       case when is_nullable = 'YES' then '' else ' NOT NULL' end as column_expr
  FROM information_schema.columns
  WHERE table_schema = 'dune_user_generated' AND table_name = $1
  ORDER BY ordinal_position) column_list;
$BODY$
  LANGUAGE SQL STABLE;