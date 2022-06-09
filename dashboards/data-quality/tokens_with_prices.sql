with bridge_tokens as (
  select distinct contract_address as token_address
  from dune_user_generated.aztec_v2_rollup_bridge_transfers
)
, paprika_tokens as (
  select distinct contract_address as token_address
      , symbol
  from prices.usd 
  where minute > '2022-05-13' 
)
, dex_tokens as (
  select distinct contract_address as token_address
    , symbol
  from prices.prices_from_dex_data
  where hour > '2022-05-13'
)
select b.token_address
  , coalesce(t.symbol, 'NOT FOUND') as symbol
  , t.decimals
  , p.token_address is not null as has_paprika_price
  , d.token_address is not null as has_dex_price
from bridge_tokens b
left join erc20.tokens t on b.token_address = t.contract_address
left join paprika_tokens p on b.token_address = p.token_address
left join dex_tokens d on b.token_address = d.token_address