-- https://dune.com/queries/874783

with transfers as (
-- from txns
    select c.protocol
        , c.contract_address as bridge_address
        , t.contract_address as token_address
        , -1.0 * value as value
        , evt_block_time
    from erc20."ERC20_evt_Transfer" t
    inner join dune_user_generated.aztec_v2_contracts c on t."from" = c.contract_address
    union all
-- to txns
    select c.protocol
        , c.contract_address as bridge_address
        , t.contract_address as token_address
        , 1.0 * value
        , evt_block_time
    from erc20."ERC20_evt_Transfer" t
    inner join dune_user_generated.aztec_v2_contracts c on t."to" = c.contract_address
)
, daily_transfers as (
    select tf.protocol
        , tf.bridge_address
        , tf.token_address
        , tk.symbol
        , tk.decimals
        , tf.evt_block_time::date as day
        , sum(tf.value) as net_value_raw
        , sum(tf.value) / 10^(coalesce(tk.decimals,18)) as net_value
        , sum(case when tf.value < 0 then tf.value else 0 end) / 10^(coalesce(tk.decimals,18)) as value_out
        , sum(case when tf.value > 0 then tf.value else 0 end) / 10^(coalesce(tk.decimals,18)) as value_in
    from transfers tf
    left join erc20.tokens tk on tf.token_address = tk.contract_address
    group by 1,2,3,4,5,6
)
select * from daily_transfers