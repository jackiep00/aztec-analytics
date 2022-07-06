-- https://dune.com/queries/1007310

create or replace view dune_user_generated.aztec_v2_rollup_inner_proofs as 
with inner_proofs as (
    select rollupid
        , call_block_time
        , (unnest(innerproofs)).*
    from dune_user_generated.aztec_v2_rollups_parsed_cached
)
select i.*
    , substring(publicowner from 13 for 20) as publicowner_norm -- publicowner is 32 bytes long, with 12 bytes of padding over the 20 bytes of ethereum address
    , a.symbol
    , a.decimals
    , i.publicvalue * 1.0 / 10 ^ (coalesce(a.decimals, 18)) as publicvalue_norm -- what does it mean for publicvalue to be populated but assetID to be null?
from inner_proofs i
left join dune_user_generated.aztec_v2_view_deposit_assets a on i.assetid = a.asset_id
;

/*
-- what does it mean for publicvalue to be populated but assetID to be null?
with inner_proofs as (
    select rollupid
        , call_block_time
        , (unnest(innerproofs)).*
    from dune_user_generated.aztec_v2_rollups_parsed_cached
)
select *
from inner_proofs i
where publicvalue > 0
and assetid is null
*/