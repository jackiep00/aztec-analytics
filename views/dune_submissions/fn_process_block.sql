drop type if exists aztec_v2.inner_proof_data_struct cascade;

drop type if exists aztec_v2.proof_data_struct cascade;

create type aztec_v2.inner_proof_data_struct as (
  proofId numeric,
  noteCommitment1 bytea,
  noteCommitment2 bytea,
  nullifier1 bytea,
  nullifier2 bytea,
  publicValue bytea,
  publicOwner bytea,
  assetId bytea
);

create type aztec_v2.proof_data_struct as (
  rollupId numeric,
  rollupSize numeric,
  dataStartIndex numeric,
  oldDataRoot bytea,
  newDataRoot bytea,
  oldNullRoot bytea,
  newNullRoot bytea,
  oldDataRootsRoot bytea,
  newDataRootsRoot bytea,
  oldDefiRoot bytea,
  newDefiRoot bytea,
  bridgeIds bytea [],
  defiDepositSums numeric [],
  assetIds numeric [],
  totalTxFees numeric [],
  defiInteractionNotes bytea [],
  prevDefiInteractionHash bytea,
  rollupBeneficiary bytea,
  numRollupTxs numeric,
  innerProofs aztec_v2.inner_proof_data_struct []
);

DROP FUNCTION if exists aztec_v2.fn_process_block(data bytea);
create
or replace function aztec_v2.fn_process_block(data bytea) returns aztec_v2.proof_data_struct as 
$$
declare 

proofData aztec_v2.proof_data_struct;

-- array & struct placeholders
bridgeIds bytea [];
defiDepositSums numeric [];
assetIds numeric [];
totalTxFees numeric [];
defiInteractionNotes bytea [];
innerProofs aztec_v2.inner_proof_data_struct [];
innerProof aztec_v2.inner_proof_data_struct;

-- counter variables
startIndex integer = 11 * 32;
innerProofStartIndex integer;
innerProofDataLength integer;
innerProofByteData bytea;
proofId integer;
rollupSize numeric;
innerOffset integer;

-- fixed constants
NUM_BRIDGE_CALLS_PER_BLOCK numeric = 32;
NUMBER_OF_ASSETS numeric = 16;
LENGTH_ROLLUP_HEADER_INPUTS numeric = 4544;
INNER_PROOF_ENCODED_LENGTH numeric = 1;
EMPTY_BYTES_12 bytea = '\x000000000000000000000000';
EMPTY_BYTES_28 bytea = '\x00000000000000000000000000000000000000000000000000000000';
EMPTY_BYTES_32 bytea = '\x0000000000000000000000000000000000000000000000000000000000000000';

begin

rollupSize = bytea2numeric(substring(data, 61, 4), false);

for i in 0..NUM_BRIDGE_CALLS_PER_BLOCK - 1 
loop 

bridgeIds = array_append(bridgeIds, substring(data, startIndex + 1, 32));
startIndex = startIndex + 32;

end loop;

for i in 0..NUM_BRIDGE_CALLS_PER_BLOCK - 1 loop defiDepositSums = array_append(
  defiDepositSums,
  bytea2numeric(substring(data, startIndex + 1, 32), false)
);

startIndex = startIndex + 32;

end loop;

for i in 0..NUMBER_OF_ASSETS - 1 
loop 

assetIds = array_append(
  assetIds,
  bytea2numeric(substring(data, startIndex + 28 + 1, 4), false)
);
startIndex = startIndex + 32;

end loop;

for i in 0..NUMBER_OF_ASSETS - 1 
loop

totalTxFees = array_append(
  totalTxFees,
  bytea2numeric(substring(data, startIndex + 1, 32), false)
);
startIndex = startIndex + 32;

end loop;

for i in 0..NUM_BRIDGE_CALLS_PER_BLOCK - 1 
loop 

defiInteractionNotes = array_append(
  defiInteractionNotes,
  substring(data, startIndex + 1, 32)
);
startIndex = startIndex + 32;

end loop;

innerProofStartIndex = LENGTH_ROLLUP_HEADER_INPUTS;

-- skip over numRealtxs
innerProofStartIndex = innerProofStartIndex + 4;
innerProofDataLength = bytea2numeric(substring(data, innerProofStartIndex + 1, 4), false);

innerProofStartIndex = innerProofStartIndex + 4;

while innerProofDataLength > 0 
loop 

innerProofByteData = substring(data, innerProofStartIndex, length(data));
proofId = bytea2numeric(substring(data, innerProofStartIndex + 1, 1), false);

case
  proofId -- deposit, withdraw
  when 1, 2 then
  
innerOffset = 2;
select
  --   proofId numeric
  proofId,
  --   noteCommitment1 bytea,
  substring(innerProofByteData, innerOffset + 1, 32),
  --   noteCommitment2 bytea,
  substring(innerProofByteData, innerOffset + 32 + 1, 32),
  --   nullifier1 bytea,
  substring(innerProofByteData, innerOffset + 32 + 32 + 1, 32),
  --   nullifier2 bytea,
  substring(innerProofByteData, innerOffset + 32 + 32 + 32 + 1, 32),
  --   publicValue bytea,
  substring(innerProofByteData, innerOffset + 32 + 32 + 32 + 32 + 1, 32),
  --   publicOwner bytea,
  EMPTY_BYTES_12 || substr(
    innerProofByteData,
    innerOffset + 32 + 32 + 32 + 32 + 32 + 1,
    20
  ),
  --   assetId bytea
  EMPTY_BYTES_28 || substr(
    innerProofByteData,
    innerOffset + 32 + 32 + 32 + 32 + 32 + 20 + 1,
    4
  ) into innerProof;
  
  INNER_PROOF_ENCODED_LENGTH = 1 + 5 * 32 + 20 + 4;
  
-- send, account, defi_deposit, defi_claim
when 3,
4,
5,
6 then

innerOffset = 2;
select
  --   proofId numeric
  proofId,
  --   noteCommitment1 bytea,
  substring(innerProofByteData, innerOffset + 1, 32),
  --   noteCommitment2 bytea,
  substring(innerProofByteData, innerOffset + 32 + 1, 32),
  --   nullifier1 bytea,
  substring(innerProofByteData, innerOffset + 32 + 32 + 1, 32),
  --   nullifier2 bytea,
  substring(innerProofByteData, innerOffset + 32 + 32 + 32 + 1, 32),
  --   publicValue bytea,
  EMPTY_BYTES_32,
  --   publicOwner bytea,
  EMPTY_BYTES_32,
  --   assetId bytea
  EMPTY_BYTES_32 into innerProof;
  
  INNER_PROOF_ENCODED_LENGTH = 1 + 4 * 32;

-- padding
else
select
  proofId,
  --   noteCommitment1 bytea,
  EMPTY_BYTES_32,
  --   noteCommitment2 bytea,
  EMPTY_BYTES_32,
  --   nullifier1 bytea,
  EMPTY_BYTES_32,
  --   nullifier2 bytea,
  EMPTY_BYTES_32,
  --   publicValue bytea,
  EMPTY_BYTES_32,
  --   publicOwner bytea,
  EMPTY_BYTES_32,
  --   assetId bytea
  EMPTY_BYTES_32 into innerProof;
  
  INNER_PROOF_ENCODED_LENGTH = 1;
end case;

innerProofs = array_append(innerProofs, innerProof);
innerProofStartIndex = innerProofStartIndex + INNER_PROOF_ENCODED_LENGTH;
innerProofDataLength = innerProofDataLength - INNER_PROOF_ENCODED_LENGTH;

end loop;

select
  -- rollupId
  bytea2numeric(substring(data, 29, 4), false),
  -- rollupSize
  rollupSize,
  -- dataStartIndex
  bytea2numeric(substring(data, 93, 4), false),
  -- oldDataRoot
  substring(data, 97, 32),
  -- newDataRoot
  substring(data, 129, 32),
  -- oldNullRoot
  substring(data, 161, 32),
  -- newNullRoot
  substring(data, 193, 32),
  -- oldDataRootsRoot
  substring(data, 225, 32),
  -- newDataRootsRoot
  substring(data, 257, 32),
  -- oldDefiRoot
  substring(data, 289, 32),
  -- newDefiRoot
  substring(data, 321, 32),
  -- bridgeIds
  bridgeIds,
  -- defiDepositSums
  defiDepositSums,
  -- assetIds
  assetIds,
  -- totalTxFees
  totalTxFees,
  -- defiInteractionNotes
  defiInteractionNotes,
  -- prevDefiInteractionHash
  substring(data, startIndex + 1, 32),
  -- rollupBeneficiary
  substring(data, startIndex + 32 + 1, 32),
  -- numRollupTxs
  bytea2numeric(substring(data, startIndex + 32 + 32 + 1, 32), false),
  -- innerProofs
  innerProofs 
into proofData;

RETURN proofData;

-- return query
-- select
--   (
--     bytea2numeric(susbstr(_data, 0, 10), false),
--     bytea2numeric(susbstr(_data, 11, 20), false)
--   ):: aztec_v2.proof_data_struct as result
-- from
--   _data;
end;

$$LANGUAGE PLPGSQL;