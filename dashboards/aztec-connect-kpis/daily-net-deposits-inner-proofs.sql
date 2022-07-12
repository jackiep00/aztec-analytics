-- https://dune.com/queries/1033052

with daily_eth_price_usd as (
  select minute::date as date
    , avg(price) as eth_price
  from prices.layer1_usd p
  where p.minute >= '2022-06-01'
  and symbol = 'ETH'
  group by 1
)
, prices as (
    select * from aztec_v2.daily_token_prices
    union
  select '\xeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee'::bytea as token_address
    , 'ETH' as symbol
    , date
    , 'prices.layer1_usd' as data_source
    , eth_price as avg_price_usd
    , eth_price
    , 1 as avg_price_eth
  from daily_eth_price_usd
 )
, deposits_withdrawals as (
    select rip.rollupid
        , rip.call_block_time
        , rip.prooftype
        , rip.assetid
        , a.asset_address
        , rip.symbol
        , rip.publicvalue_norm
        , p.avg_price_usd
        , rip.publicvalue_norm * p.avg_price_usd as value_usd
    from aztec_v2.rollup_inner_proofs rip
    inner join aztec_v2.view_deposit_assets a on rip.assetid = a.asset_id
    inner join prices p on a.asset_address = p.token_address
        and rip.call_block_time::date = p.date
    where prooftype in ('DEPOSIT', 'WITHDRAW')
)
select call_block_time::date as date
    , count(distinct rollupid) as num_rollups
    , count(*) as num_txns
    , count(case when prooftype = 'DEPOSIT' then 1 else null end) as num_deposits
    , count(case when prooftype = 'WITHDRAW' then 1 else null end) as num_withdrawals
    , sum(case when prooftype = 'DEPOSIT' then value_usd else 0 end) as deposit_value_usd
    , -1 * sum(case when prooftype = 'WITHDRAW' then value_usd else 0 end) as withdrawal_value_usd
    , sum(case when prooftype = 'DEPOSIT' then value_usd else 0 end) - 
        sum(case when prooftype = 'WITHDRAW' then value_usd else 0 end) as net_deposit_value_usd
from deposits_withdrawals
group by 1
