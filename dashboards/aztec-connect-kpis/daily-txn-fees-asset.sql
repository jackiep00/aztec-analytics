-- https://dune.com/queries/1064502
    select symbol
        , sum(total_tx_fee_norm) as cum_txn_fees_units
    from aztec_v2.view_rollup_txn_fees
    group by 1
