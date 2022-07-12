-- https://dune.com/queries/907408
with daily_gas_paid as (
    select block_time::date as date
        -- , gas_price/10^9 AS gas_prices
        -- , gas_used
        , sum((gas_price*gas_used)/10^18) AS eth_paid_for_tx
    from ethereum.transactions t
    -- where hash = '\x4ee1730c2f9bc306ec33523c9f3bb6c53d9f40c5dc94740bc42692ceb4910226'::bytea
    -- where t."from" = '\xFF1F2B4ADb9dF6FC8eAFecDcbF96A2B351680455'::bytea
    inner join aztec_v2.contract_labels c on t."to" = c.contract_address
    where c.contract_type = 'Rollup'
    group by 1
)
, day_series as (
    select generate_series(min(date), now()::date,interval '1 day') as date
    from daily_gas_paid
)
select d.date
    , coalesce(g.eth_paid_for_tx,0) as eth_paid_for_gas
    , sum(g.eth_paid_for_tx) over (order by d.date asc) as cum_eth_paid_for_gas
from day_series d
left join daily_gas_paid g on d.date = g.date