#!/bin/bash
PROVENANCE_DEV_DIR=~/code/provenance
COMMON_TX_FLAGS="--chain-id testing --keyring-backend test --yes -o json"
GAS_FLAGS="--gas auto --gas-prices 1905nhash"
GAS_ADJUSTMENT="--gas-adjustment 2"
VALIDATOR_ID=$(${PROVENANCE_DEV_DIR}/build/provenanced keys show -a validator --home ${PROVENANCE_DEV_DIR}/build/run/provenanced -t)
BUYER=$(${PROVENANCE_DEV_DIR}/build/provenanced keys show -a buyer --home ${PROVENANCE_DEV_DIR}/build/run/provenanced -t)
SELLER=$(${PROVENANCE_DEV_DIR}/build/provenanced keys show -a seller --home ${PROVENANCE_DEV_DIR}/build/run/provenanced -t)

echo "Generating send...to be used for simulation"
${PROVENANCE_DEV_DIR}/build/provenanced -t --home ${PROVENANCE_DEV_DIR}/build/run/provenanced tx bank send ${VALIDATOR_ID} ${SELLER} 100000000000nhash  \
    --from validator --generate-only | jq > tmp.generated.send.json
echo "Signing send....to be used for simulation"
${PROVENANCE_DEV_DIR}/build/provenanced -t --home ${PROVENANCE_DEV_DIR}/build/run/provenanced tx sign tmp.generated.send.json --from ${VALIDATOR_ID} ${COMMON_TX_FLAGS} | jq> tmp.generated.send.json.signed
echo "Run Simulate through custom pio simulate to capture any additional fees using gas adjustment ${GAS_ADJUSTMENT}"
${PROVENANCE_DEV_DIR}/build/provenanced -t --home ${PROVENANCE_DEV_DIR}/build/run/provenanced tx simulate tmp.generated.send.json.signed ${COMMON_TX_FLAGS} --from ${VALIDATOR_ID} ${GAS_ADJUSTMENT} | jq
# echo "Broadcasting send..."
# ${PROVENANCE_DEV_DIR}/build/provenanced -t --home ${PROVENANCE_DEV_DIR}/build/run/provenanced tx broadcast tmp.generated.send.json.signed --from validator ${COMMON_TX_FLAGS} | jq

rm  tmp.generated.send.json*

echo "Execute send with ${GAS_FLAGS} ${GAS_ADJUSTMENT}.  With gas auto option being set, cosmos-sdk will run a simple simulate and print out estimated gas (gas * gas-adjustment).  Should be clost to previous pio simulate call."
${PROVENANCE_DEV_DIR}/build/provenanced -t --home ${PROVENANCE_DEV_DIR}/build/run/provenanced tx bank send ${VALIDATOR_ID} ${SELLER} 100000000000nhash  \
    --from validator  \
    ${COMMON_TX_FLAGS} ${GAS_FLAGS} ${GAS_ADJUSTMENT} | jq