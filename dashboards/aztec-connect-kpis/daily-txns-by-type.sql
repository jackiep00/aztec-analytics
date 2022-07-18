-- https://dune.com/queries/1063092

select date_trunc('week',call_block_time) as week
    , prooftype
    , count(*) as num_txns
from aztec_v2.view_rollup_inner_proofs
where prooftype <> 'PADDING'
group by 1,2