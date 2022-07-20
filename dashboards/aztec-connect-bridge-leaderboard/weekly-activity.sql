-- https://dune.com/queries/895776
with week_series as (
    select generate_series(date_trunc('week',min(date)), date_trunc('week',now()), '1 week') as week
    from aztec_v2.view_daily_bridge_activity
)
, weekly_data as (
    select date_trunc('week', date) as week 
        , count(distinct bridge_address) as bridge_contracts_active
        , sum(abs_volume_usd) as volume_usd
        , sum(num_rollups) as num_rollups -- a "txn" on L1 is actually an entire rollup of Aztec txns
        , sum(abs_volume_usd) / sum(num_rollups) as avg_rollup_size_usd
    from aztec_v2.view_daily_bridge_activity
    group by 1
    order by 1 desc
)
, weekly_inner_proofs as (
    select date_trunc('week',call_block_time) as week
        , count(*) as num_defi_txns
    from aztec_v2.view_rollup_inner_proofs
    where prooftype in ('DEFI_CLAIM', 'DEFI_DEPOSIT')
    group by 1
)
select w.week
    , coalesce(bridge_contracts_active,0) as bridge_contracts_active
    , coalesce(volume_usd,0) as volume_usd
    , coalesce(num_rollups,0) as num_rollups
    , coalesce(num_defi_txns,0) as num_defi_txns
    , coalesce(avg_rollup_size_usd,0) as avg_rollup_size_usd
    , coalesce(volume_usd,0) * 1.0 / num_defi_txns as avg_txn_size_usd
from week_series w
left join weekly_data d on w.week = d.week
left join weekly_inner_proofs wip on w.week = wip.week
order by 1 desc