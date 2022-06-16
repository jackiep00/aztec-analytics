-- https://dune.com/queries/909707

-- this query does not include beta rollup transactions
with daily_rollup_counts as (
  select date_trunc('day', evt_block_time) as date
    , count(*) as num_rollups
  from aztec_v2."RollupProcessor_evt_RollupProcessed" r
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

