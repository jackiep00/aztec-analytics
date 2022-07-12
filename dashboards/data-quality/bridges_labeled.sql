-- https://dune.com/queries/892818

-- Prelaunch Bridges
/*
select "bridgeAddress"
    , (CONCAT('<a href="https://etherscan.io/address/0'
        , SUBSTRING("bridgeAddress"::text, 2, 42), '">0'
        , SUBSTRING("bridgeAddress"::text, 2, 5),'...'
        ,SUBSTRING("bridgeAddress"::text, 39, 42), '</a>')) as link
    , coalesce(l.protocol, 'UNLABELED') as protocol_label
    , l.version as label_version
    , l.description
from aztec_v2."RollupProcessorPreLaunch_evt_BridgeAdded" b
left join dune_user_generated.aztec_v2_contract_labels l on b."bridgeAddress" = l.contract_address
union
*/
-- Production bridges
select distinct "bridgeAddress"
    , (CONCAT('<a href="https://etherscan.io/address/0'
        , SUBSTRING("bridgeAddress"::text, 2, 42), '">0'
        , SUBSTRING("bridgeAddress"::text, 2, 5),'...'
        ,SUBSTRING("bridgeAddress"::text, 39, 42), '</a>')) as link
    , coalesce(l.protocol, 'UNLABELED') as protocol_label
    , l.version as label_version
    , l.description
from aztec_v2."RollupProcessor_evt_BridgeAdded" b
left join aztec_v2.contract_labels l on b."bridgeAddress" = l.contract_address