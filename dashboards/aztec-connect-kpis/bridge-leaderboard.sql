-- https://dune.com/queries/906060

select bridge_protocol
    , l.description
    , sum(abs_volume_usd) as all_time_volume_usd
    , sum(case when date between now() and now() - interval '7 days' then abs_volume_usd else 0 end) as "7_day_volume"
    , sum(case when date = now() then abs_volume_usd else 0 end) as last_day_volume
    , sum(num_rollups) as all_time_rollups
    , sum(case when date between now() and now() - interval '7 days' then num_rollups else 0 end) as "7_day_rollups"
    , sum(case when date = now() then num_rollups else 0 end) as last_day_rollups
    , l.contract_creator as bridge_deployer
    , bridge_address    
from dune_user_generated.view_aztec_v2_daily_bridge_activity b
inner join dune_user_generated.aztec_v2_contract_labels l on b.bridge_address = l.contract_address
group by 1,2,l.contract_creator,bridge_address
order by 3 desc