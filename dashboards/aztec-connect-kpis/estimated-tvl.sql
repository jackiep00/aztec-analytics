-- https://dune.com/queries/906672

select date
  , sum(tvl_usd) as tvl_usd
  , sum(tvl_eth) as tvl_eth
from dune_user_generated.aztec_v2_daily_estimated_rollup_tvl
group by 1
