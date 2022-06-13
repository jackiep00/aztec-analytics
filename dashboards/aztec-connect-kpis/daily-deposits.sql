-- https://dune.com/queries/905968

with day_series as (
    select generate_series(min(date), now()::date, '1 day') as date
    from dune_user_generated.view_aztec_v2_daily_deposits
)
select d.date
    , sum(user_deposits_usd) as deposits_usd
    , -1 * sum(user_withdrawals_usd) as withdrawals_usd
    , sum(user_deposits_usd) - sum(user_withdrawals_usd) as net_deposits_usd
from day_series d
left join dune_user_generated.view_aztec_v2_daily_deposits dp on d.date = dp.date
group by 1
;