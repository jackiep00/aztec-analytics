-- https://dune.com/queries/1063078

with date_series as (
    select generate_series(min(call_block_time::date), now()::date, interval '1 day') as date
    from aztec_v2.view_rollup_txn_fees
)
, daily_txn_fees as (
    select call_block_time::date as date
        , sum(total_tx_fee_usd) as txn_fee_usd
    from aztec_v2.view_rollup_txn_fees
    group by 1
)
select d.date
    , coalesce(dtf.txn_fee_usd, 0) as txn_fee_usd
    , sum(dtf.txn_fee_usd) over (order by d.date asc) as cum_txn_fee_usd
from date_series d
left join daily_txn_fees dtf on d.date = dtf.date
