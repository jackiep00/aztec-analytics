-- https://dune.com/queries/906009

with first_deposit_dates as (
  select rip.publicowner_norm
        , min(rip.call_block_time::date) as first_deposit_date
    from aztec_v2.view_rollup_inner_proofs rip
    where prooftype in ('DEPOSIT')
    -- where prooftype in ('DEPOSIT', 'WITHDRAW')
    -- use the above if you want to include withdrawers as "users"
    group by 1
)
, first_depositor_counts as (
  select first_deposit_date
    , count(*) as num_depositors
  from first_deposit_dates
  group by 1
)
, date_series as (
  select generate_series(min(first_deposit_date),now()::date,interval '1 day') as date
  from first_depositor_counts
)
, cum_depositors as (
  select d.date
    , coalesce(num_depositors,0) as num_depositors
    , sum(num_depositors) over (order by d.date) as total_depositors
  from date_series d
  left join first_depositor_counts f on d.date = f.first_deposit_date
)
select * from cum_depositors
order by 1 desc