-- https://dune.com/queries/895849

select count (distinct "bridgeAddress") as num_bridges
from aztec_v2."RollupProcessor_evt_BridgeAdded" b