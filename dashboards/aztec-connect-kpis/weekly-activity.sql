-- https://dune.com/queries/895776

select date_trunc('week', date) as week 
    , count(distinct bridge_address) as bridge_contracts_active
    , sum(abs_volume_usd) as volume_usd
    , sum(num_rollups) as num_rollups -- a "txn" on L1 is actually an entire rollup of Aztec txns
    , sum(abs_volume_usd) / sum(num_rollups) as avg_rollup_size_usd
from dune_user_generated.view_aztec_v2_daily_bridge_activity
group by 1
order by 1 desc
