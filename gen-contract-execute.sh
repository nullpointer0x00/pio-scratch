#!/bin/bash
PROVENANCE_DEV_DIR=~/code/provenance
COMMON_TX_FLAGS="--chain-id testing --keyring-backend test --yes -o json"
VALIDATOR_ID=$(${PROVENANCE_DEV_DIR}/build/provenanced keys show -a validator --home ${PROVENANCE_DEV_DIR}/build/run/provenanced -t)
BUYER=$(${PROVENANCE_DEV_DIR}/build/provenanced keys show -a buyer --home ${PROVENANCE_DEV_DIR}/build/run/provenanced -t)
SELLER=$(${PROVENANCE_DEV_DIR}/build/provenanced keys show -a seller --home ${PROVENANCE_DEV_DIR}/build/run/provenanced -t)
PIO_ENV_FLAGS="-t --home ${PROVENANCE_DEV_DIR}/build/run/provenanced"
PROVENANCE_DEV_BUILD=build/provenanced
PIO_CMD="${PROVENANCE_DEV_DIR}/${PROVENANCE_DEV_BUILD} ${PIO_ENV_FLAGS}"

export MERCHANT=$(${PIO_CMD} keys show -a merchant)
export FEEBUCKET=$(${PIO_CMD} keys show -a feebucket)

export SEND_FUNDS='{"send_funds":{"funds":{"amount":"1","denom":"nhash"},"to_address":"'${MERCHANT}'"}}'
export CONTRACT=$(${PIO_CMD} query wasm list-contract-by-code 1 -o json | jq -r ".contracts[1]")
echo $CONTRACT
# echo "Generating send...to be used for simulation"
# ${PIO_CMD} tx wasm execute ${CONTRACT} ${SEND_FUNDS} --amount 1nhash --chain-id testing --keyring-backend test --from validator --generate-only | jq > tmp.generated.contract.json
echo "Signing send....to be used for simulation"
${PIO_CMD} tx sign tmp.generated.contract.json --from ${VALIDATOR_ID} ${COMMON_TX_FLAGS} | jq> tmp.generated.contract.json.signed
echo "Run Simulate through custom pio simulate to capture any additional fees using gas adjustment"
${PIO_CMD} tx simulate tmp.generated.contract.json.signed ${COMMON_TX_FLAGS} --from ${VALIDATOR_ID} --fees 10000000000nhash | jq
echo "Broadcasting send..."
${PIO_CMD} tx broadcast tmp.generated.send.json.signed --from validator ${COMMON_TX_FLAGS} | jq

# rm  tmp.generated.send.json*

# echo "Execute send with ${GAS_FLAGS} ${GAS_ADJUSTMENT}.  With gas auto option being set, cosmos-sdk will run a simple simulate and print out estimated gas (gas * gas-adjustment).  Should be clost to previous pio simulate call."
# ${PIO_CMD} tx bank send ${VALIDATOR_ID} ${SELLER} 100000000000nhash  \
#     --from validator  \
#     ${COMMON_TX_FLAGS} ${GAS_FLAGS} ${GAS_ADJUSTMENT} | jq