#!/bin/bash
PROVENANCE_DEV_DIR=~/code/provenance
COMMON_TX_FLAGS="--chain-id testing --keyring-backend test --yes -o json"
GAS_FLAGS="--gas auto --gas-prices 1905nhash"
GAS_ADJUSTMENT="--gas-adjustment 1"
VALIDATOR_ID=$(${PROVENANCE_DEV_DIR}/build/provenanced keys show -a validator --home ${PROVENANCE_DEV_DIR}/build/run/provenanced -t)
BUYER=$(${PROVENANCE_DEV_DIR}/build/provenanced keys show -a buyer --home ${PROVENANCE_DEV_DIR}/build/run/provenanced -t)
SELLER=$(${PROVENANCE_DEV_DIR}/build/provenanced keys show -a seller --home ${PROVENANCE_DEV_DIR}/build/run/provenanced -t)
PIO_ENV_FLAGS="-t --home ${PROVENANCE_DEV_DIR}/build/run/provenanced"
PROVENANCE_DEV_BUILD=build/provenanced
PIO_CMD="${PROVENANCE_DEV_DIR}/${PROVENANCE_DEV_BUILD} ${PIO_ENV_FLAGS}"

echo "Generating send...to be used for simulation"
# ${PIO_CMD} tx bank send ${VALIDATOR_ID} ${SELLER} 100000000000nhash  \
#     --from validator --generate-only | jq > tmp.generated.send.json
# ${PIO_CMD} tx metadata write-scope scope1qzhpuff00wpy2yuf7xr0rp8aucqstsk0cn scopespec1qjpreurq8n7ylc4y5zw6gn255lkqle56sv ${VALIDATOR_ID} ${VALIDATOR_ID} ${VALIDATOR_ID}   \
#     --from ${VALIDATOR_ID} --generate-only | jq > tmp.generated.send.json
echo "Signing send....to be used for simulation"
${PIO_CMD} tx sign tmp.generated.send.copy.json --from ${VALIDATOR_ID} ${COMMON_TX_FLAGS} | jq> tmp.generated.send.json.signed
echo "Run Simulate through custom pio simulate to capture any additional fees using gas adjustment ${GAS_ADJUSTMENT}"
${PIO_CMD} tx simulate tmp.generated.send.json.signed ${COMMON_TX_FLAGS} --from ${VALIDATOR_ID} ${GAS_ADJUSTMENT} | jq
# echo "Broadcasting send..."
# ${PIO_CMD} tx broadcast tmp.generated.send.json.signed --from validator ${COMMON_TX_FLAGS} | jq

# rm  tmp.generated.send.json*

# echo "Execute send with ${GAS_FLAGS} ${GAS_ADJUSTMENT}.  With gas auto option being set, cosmos-sdk will run a simple simulate and print out estimated gas (gas * gas-adjustment).  Should be clost to previous pio simulate call."
# ${PIO_CMD} tx bank send ${VALIDATOR_ID} ${SELLER} 100000000000nhash  \
#     --from validator  \
#     ${COMMON_TX_FLAGS} ${GAS_FLAGS} ${GAS_ADJUSTMENT} | jq
