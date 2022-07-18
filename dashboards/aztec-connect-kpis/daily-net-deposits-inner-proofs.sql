-- https://dune.com/queries/1033052

select call_block_time::date as date
    , count(distinct rollupid) as num_rollups
    , count(*) as num_txns
    , count(case when prooftype = 'DEPOSIT' then 1 else null end) as num_deposits
    , count(case when prooftype = 'WITHDRAW' then 1 else null end) as num_withdrawals
    , sum(case when prooftype = 'DEPOSIT' then publicvalue_usd else 0 end) as deposit_value_usd
    , -1 * sum(case when prooftype = 'WITHDRAW' then publicvalue_usd else 0 end) as withdrawal_value_usd
    , sum(case when prooftype = 'DEPOSIT' then publicvalue_usd else 0 end) - 
        sum(case when prooftype = 'WITHDRAW' then publicvalue_usd else 0 end) as net_deposit_value_usd
from aztec_v2.view_rollup_inner_proofs
where prooftype in ('DEPOSIT', 'WITHDRAW')
group by 1
;