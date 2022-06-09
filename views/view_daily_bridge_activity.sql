create view dune_user_generated.view_aztec_v2_daily_bridge_activity as 
with daily_transfers as (
    select date_trunc('day', evt_block_time) as date
        , bridge_protocol
        , bridge_address
        , contract_address as token_address
        , count(*) as num_txns
        , sum(value_norm) as abs_value_norm
    from dune_user_generated.aztec_v2_rollup_bridge_transfers
    where bridge_protocol is not null -- exclude all txns that don't interact with the bridges
    group by 1,2,3,4
)
, daily_volume as (
    select dt.date
        , dt.bridge_protocol
        , dt.bridge_address
        , dt.token_address
        , p.symbol
        , dt.num_txns
        , dt.abs_value_norm
        , dt.abs_value_norm * p.avg_price_usd as abs_volume_usd
        , dt.abs_value_norm * p.avg_price_eth as abs_volume_eth
    from daily_transfers dt
    inner join dune_user_generated.table_aztec_v2_daily_bridged_tokens_prices_cached p on dt.date = p.date
        and dt.token_address = p.token_address
-- inner join dune_user_generated.view_aztec_v2_daily_bridged_tokens_prices p on dt.date = p.date
)
select * from daily_volume