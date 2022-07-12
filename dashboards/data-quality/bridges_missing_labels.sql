-- https://dune.com/queries/892852/1560562

select count (distinct "bridgeAddress") as num_unlabeled_bridges
from aztec_v2."RollupProcessor_evt_BridgeAdded" b
left join aztec_v2.contract_labels l on b."bridgeAddress" = l.contract_address
where l.contract_address is null