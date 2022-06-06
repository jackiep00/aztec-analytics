-- https://dune.com/queries/874721

-- prototype alias table for Aztec V2
create table if not exists dune_user_generated.aztec_v2_contracts
(
  protocol varchar,               
  version varchar,            
  contract_address bytea                       
);

create index on dune_user_generated.aztec_v2_contracts(contract_address);
create index on dune_user_generated.aztec_v2_contracts(protocol);

truncate table dune_user_generated.aztec_v2_contracts;

insert into dune_user_generated.aztec_v2_contracts 
(protocol,               version,            contract_address) values
('Element',              '0.1',              '\xb5e0Ab45C2c48a6F7032Ee0db749c3c9C5c58A32'::bytea),
('Aztec RollupProcessor','0.1',              '\xff6bed1e4d28491b89a02dc56b34a4b273eb9e0d'::bytea),
('Lido',                 '0.1',              '\xFDb2f2E720436972644bf824dEBea47F07C5041D'::bytea)
;