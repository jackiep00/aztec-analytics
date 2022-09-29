-- https://dune.com/queries/906311

select bridge_protocol
    , l.description
    , symbol as token_symbol
    , sum(input_volume_usd) as all_time_volume_usd
    , sum(case when date between now()::date - interval '6 days' and now()::date then input_volume_usd else 0 end) as "7_day_volume"
    , sum(case when date = now()::date then input_volume_usd else 0 end) as last_day_volume
    , sum(num_rollups) as all_time_rollups
    , sum(case when date between now()::date - interval '6 days' and now()::date then num_rollups else 0 end) as "7_day_rollups"
    , sum(case when date = now()::date then num_rollups else 0 end) as last_day_rollups
    , token_address as token_address
    , l.contract_creator as bridge_deployer
    , bridge_address    
from aztec_v2.view_daily_bridge_activity b
inner join aztec_v2.contract_labels l on b.bridge_address = l.contract_address
group by 1,2,3, token_address, l.contract_creator,bridge_address
order by 4 desc