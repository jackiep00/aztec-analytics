-- https://dune.com/queries/906672

select date
  , sum(tvl_usd) as tvl_usd
  , sum(tvl_eth) as tvl_eth
from aztec_v2.view_daily_estimated_rollup_tvl
group by 1
order by 1 desc