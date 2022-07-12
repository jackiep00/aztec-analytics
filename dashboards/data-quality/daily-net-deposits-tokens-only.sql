-- https://dune.com/queries/905968
-- This query only includes erc20 tokens and doesn't capture ETH values.

with day_series as (
    select generate_series(min(date), now()::date, '1 day') as date
    from aztec_v2.view_daily_deposits
)
select d.date
    , sum(user_deposits_usd) as deposits_usd
    , -1 * sum(user_withdrawals_usd) as withdrawals_usd
    , sum(user_deposits_usd) - sum(user_withdrawals_usd) as net_deposits_usd
from day_series d
left join aztec_v2.view_daily_deposits dp on d.date = dp.date
group by 1
;