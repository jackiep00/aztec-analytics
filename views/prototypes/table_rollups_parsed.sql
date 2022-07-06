-- https://dune.com/queries/950362

drop table dune_user_generated.aztec_v2_rollups_parsed_cached;

create table dune_user_generated.aztec_v2_rollups_parsed_cached as
select
  "call_block_time"
  , contract_address
  , call_tx_hash
  , (dune_user_generated.fn_process_aztec_block("_0")).*
from
  aztec_v2."RollupProcessor_call_processRollup"
order by
  1