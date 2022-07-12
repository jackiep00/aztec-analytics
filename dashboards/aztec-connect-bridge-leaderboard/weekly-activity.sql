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
select w.week
    , coalesce(bridge_contracts_active,0) as bridge_contracts_active
    , coalesce(volume_usd,0) as volume_usd
    , coalesce(num_rollups,0) as num_rollups
    , coalesce(avg_rollup_size_usd,0) as avg_rollup_size_usd
from week_series w
left join weekly_data d on w.week = d.week
order by 1 desc