-- https://dune.com/queries/835790

select table_type, table_schema
    , split_part(table_name,'_',1) as contract_name
    , split_part(table_name,'_',2) as trace_type
    -- , split_part(table_name,'_',3) as trace_name_1 -- this doesn't account for additional underscores
    , right(table_name,
        length(table_name) - 2 -- subtract the 2 underscores we're excluding
        - length(split_part(table_name,'_',1)) -- contract_name
        - length(split_part(table_name,'_',2)) -- trace_type
    ) as trace_name -- grab the rest of the trace name by excluding the strings we've already parsed
    , table_name
from information_schema.tables
where table_schema in ('aztec_v2') 
-- aztec v2 is Aztec Connect, aztec_v1 is just zk money
;