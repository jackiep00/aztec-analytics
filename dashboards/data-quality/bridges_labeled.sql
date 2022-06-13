-- https://dune.com/queries/892818

select "bridgeAddress"
    , (CONCAT('<a href="https://etherscan.io/address/0'
        , SUBSTRING("bridgeAddress"::text, 2, 42), '">0'
        , SUBSTRING("bridgeAddress"::text, 2, 5),'...'
        ,SUBSTRING("bridgeAddress"::text, 39, 42), '</a>')) as link
    , coalesce(l.protocol, 'UNLABELED') as protocol_label
    , l.version as label_version
from aztec_v2."RollupProcessor_evt_BridgeAdded" b
left join dune_user_generated.aztec_v2_contract_labels l on b."bridgeAddress" = l.contract_address