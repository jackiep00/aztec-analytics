-- https://dune.com/queries/874721
-- prototype alias table for Aztec V2
drop if exists table dune_user_generated.aztec_v2_contract_labels;

create table if not exists dune_user_generated.aztec_v2_contract_labels
(
  protocol varchar,
  contract_type varchar,               
  version varchar,            
  contract_address bytea                       
);

create index on dune_user_generated.aztec_v2_contract_labels(contract_address);
create index on dune_user_generated.aztec_v2_contract_labels(protocol);

truncate table dune_user_generated.aztec_v2_contract_labels;

insert into dune_user_generated.aztec_v2_contract_labels 
(protocol,               contract_type,      version,            contract_address) values
('Element',              'Bridge',           '0.1',              '\xb5e0Ab45C2c48a6F7032Ee0db749c3c9C5c58A32'::bytea),
('Aztec RollupProcessor','Rollup',           '0.1',              '\xff6bed1e4d28491b89a02dc56b34a4b273eb9e0d'::bytea),
('Lido',                 'Bridge',           '0.1',              '\xFDb2f2E720436972644bf824dEBea47F07C5041D'::bytea)
;