#!/bin/bash
PROVENANCE_DEV_DIR=~/code/provenance
PROVENANCE_DEV_BUILD=build/provenanced
PIO_ENV_FLAGS="-t --home ${PROVENANCE_DEV_DIR}/build/run/provenanced"
PIO_CMD="${PROVENANCE_DEV_DIR}/${PROVENANCE_DEV_BUILD} ${PIO_ENV_FLAGS}"
WASM_BIN_DIR=~/code/pio-scratch/wasms
COMMON_TX_FLAGS="--gas auto --gas-prices 1905nhash --gas-adjustment 2 --chain-id testing --keyring-backend test --yes -o json"


######################################### SETUP FOR ATS CONTRACT EXECUTION ##############################################

export VALIDATOR_ID=$(${PIO_CMD} keys show -a validator)
export MERCHANT=$(${PIO_CMD} keys show -a merchant)
export FEEBUCKET=$(${PIO_CMD} keys show -a feebucket)

export SEND_FUNDS='{"send_funds":{"funds":{"amount":"1","denom":"nhash"},"to_address":"'${MERCHANT}'"}}'

# export CONTRACT=$(${PIO_CMD} query wasm list-contract-by-code 1 -o json | jq -r ".contracts[0]")

# echo "Merchant Before Balance"
# ${PIO_CMD} q bank balances ${MERCHANT} -o json | jq

# echo "Feebucket Before Balance"
# ${PIO_CMD} q bank balances ${FEEBUCKET} -o json | jq

# ${PIO_CMD} tx wasm execute \
#     ${CONTRACT} \
#     ${SEND_FUNDS} \
#     --amount 1nhash \
#     --from validator \
#     --fees 1000000000nhash \
#     --chain-id testing --keyring-backend test --yes -o json | jq

# echo "Merchant After Balance"
# ${PIO_CMD} q bank balances ${MERCHANT} -o json | jq

# echo "Feebucket After Balance"
# ${PIO_CMD} q bank balances ${FEEBUCKET} -o json | jq


export CONTRACT=$(${PIO_CMD} query wasm list-contract-by-code 1 -o json | jq -r ".contracts[1]")

# ${PIO_CMD} tx bank send ${VALIDATOR_ID} ${MERCHANT} 417nhash \
#     --from validator \
#     --fees 10000000000nhash \
#     --chain-id testing --keyring-backend test --yes -o json | jq

echo "Merchant Before Balance"
${PIO_CMD} q bank balances ${MERCHANT} -o json | jq

echo "Feebucket Before Balance"
${PIO_CMD} q bank balances ${FEEBUCKET} -o json | jq

${PIO_CMD} tx wasm execute \
    ${CONTRACT} \
    ${SEND_FUNDS} \
    --amount 1nhash \
    --from validator \
    --fees 10000000000nhash \
    --chain-id testing --keyring-backend test --yes -o json | jq

echo "Merchant After Balance"
${PIO_CMD} q bank balances ${MERCHANT} -o json | jq

echo "Feebucket After Balance"
${PIO_CMD} q bank balances ${FEEBUCKET} -o json | jq