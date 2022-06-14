-- https://dune.com/queries/909707
with daily_rollup_counts as (
  select date_trunc('day', evt_block_time) as date
    , count(distinct evt_tx_hash) as num_rollups -- number of rollups
  from dune_user_generated.aztec_v2_rollup_bridge_transfers r
  where spec_txn_type in ('RP to Bridge', 'Bridge to RP')
  group by 1
)
, date_series as (
  select generate_series(min(date), now()::date, interval '1 day') as date
  from daily_rollup_counts
)
, cum_rollups as (
  select d.date
    , coalesce(num_rollups,0) as num_depositors
    , sum(num_rollups) over (order by d.date) as total_rollups
  from date_series d
  left join daily_rollup_counts r on d.date = r.date
)
select * from cum_rollups
order by 1 desc

