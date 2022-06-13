-- Cache the prices for faster iteration
drop table if exists dune_user_generated.table_aztec_v2_daily_bridged_tokens_prices_cached cascade;
create table if not exists dune_user_generated.table_aztec_v2_daily_bridged_tokens_prices_cached as
---------------------------------------------------------------------
-- Section 1: which tokens we're looking at
with tokens as (
  -- Get the relevant components
  select distinct contract_address as token_address
  from dune_user_generated.aztec_v2_rollup_bridge_transfers
)
, tokens_from_paprika as (
  select distinct contract_address as token_address
  from prices.usd p 
  where p.minute >= '2022-05-13' 
)
, missing_tokens as (
  select t.token_address
  from tokens t
  left join tokens_from_paprika tfp on t.token_address = tfp.token_address
  where tfp.token_address is null
)
---------------------------------------------------------------------
-- Section 2: CoinPaprika Price Feed
, daily_token_prices_usd_paprika as (
  select t.token_address
    , p.symbol
    , p.minute::date as date
    , avg(price) as avg_price_usd
  from tokens t
  inner join prices.usd p on t.token_address = p.contract_address
  where p.minute >= '2022-05-13' 
  group by 1,2,3
)
----------------------------------------------------------------------
-- Section 3: Dex Price Feed
, daily_token_prices_usd_dex_passing as (
  -- this part of the query applies some data quality standards to the prices_from_dex data
  -- to try and smooth out extreme price movements from illiquid DEXes
  select p.hour::date as date
    , mt.token_address
    , p.symbol
    -- , sum(sample_size) as daily_samples
    , percentile_disc(0.5) within group (order by median_price) as avg_price -- use the median price for the day to remove outliers
    -- , sum(median_price* sample_size) / sum(sample_size) as avg_price -- sample size weighted average median price
  from prices.prices_from_dex_data p
  inner join missing_tokens mt on p.contract_address = mt.token_address
  where p.hour >= '2022-05-13' 
    and sample_size > 0
  group by 1,2,3
  having sum(sample_size) > 5 -- minimum of 6 samples required to set a daily price
     and count(distinct median_price) > 5 -- minimum of 6 unique rows required
)
, daily_token_prices_usd_dex_passing_lead as (
  select date
        , token_address
        , symbol
        , avg_price
        , lead(date, 1) over (partition by token_address order by date) as next_date
            -- this gives the day that this particular snapshot value is valid until
    from daily_token_prices_usd_dex_passing 
)
, day_series as (
  SELECT generate_series(min(date), now(), '1 day') AS day 
        FROM daily_token_prices_usd_dex_passing
)
, imputed_token_prices_dex_usd as (
    select d.day as date
        , p.token_address
        , p.symbol
        , p.avg_price as avg_price_usd
    from day_series d 
    inner join daily_token_prices_usd_dex_passing_lead p
        on d.day >= p.date
        and d.day < coalesce(p.next_date,now()::date + 1) -- if it's missing that means it's the last entry in the series
)
-------------------------------------------------------------------------------------------------------------------
-- Section 4: Synthesize with ETH price
, daily_eth_price_usd as (
  select minute::date as date
    , avg(price) as eth_price
  from prices.layer1_usd p
  where p.minute >= '2022-05-13' 
  and symbol = 'ETH'
  group by 1
)
, paprika_price_feed as (
  select p.token_address
    , p.symbol
    , p.date
    , 'prices.usd' as data_source
    , p.avg_price_usd
    , e.eth_price
    , p.avg_price_usd / e.eth_price as avg_price_eth
  from daily_token_prices_usd_paprika p
  inner join daily_eth_price_usd e on p.date = e.date
)
, dex_price_feed as (
  select p.token_address
    , p.symbol
    , p.date
    , 'prices.prices_from_dex_data' as data_source
    , p.avg_price_usd
    , e.eth_price
    , p.avg_price_usd / e.eth_price as avg_price_eth
  from imputed_token_prices_dex_usd p
  inner join daily_eth_price_usd e on p.date = e.date
)
select * from paprika_price_feed
union 
select * from dex_price_feed
;
------------------------------------------------------------------------------
-- Section 5: Create some indices for the table
create index on dune_user_generated.table_aztec_v2_daily_bridged_tokens_prices_cached(token_address);
create index on dune_user_generated.table_aztec_v2_daily_bridged_tokens_prices_cached(token_address, date);

