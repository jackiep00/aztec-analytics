-- https://dune.com/queries/895776

select bridge_protocol
    , bridge_address
    , sum(abs_volume_usd) as all_time_volume_usd
    , sum(case when date between now() and now() - interval '7 days' then abs_volume_usd else 0 end) as 7_day_volume
    , sum(case when date = now() then abs_volume_usd else 0 end) as last_day_volume
from dune_user_generated.view_aztec_v2_daily_bridge_activity
