#!/bin/bash
PROVENANCE_DEV_DIR=~/code/provenance
PROVENANCE_DEV_BUILD=build/provenanced
PIO_ENV_FLAGS="-t --home ${PROVENANCE_DEV_DIR}/build/run/provenanced"
PIO_CMD="${PROVENANCE_DEV_DIR}/${PROVENANCE_DEV_BUILD} ${PIO_ENV_FLAGS}"
WASM_BIN_DIR=~/code/pio-scratch/wasms
COMMON_TX_FLAGS="--gas auto --gas-prices 1905nhash --gas-adjustment 2 --chain-id testing --keyring-backend test --yes -o json"
MNEMONICS_DIR=~/code/pio-scratch/mnemonics

######################################### SETUP FOR TEST ASSESS FEES CONTRACT EXECUTION ##############################################
${PIO_CMD} keys add buyer --recover --keyring-backend test < ${MNEMONICS_DIR}/buyer.txt
${PIO_CMD} keys add seller --recover --keyring-backend test < ${MNEMONICS_DIR}/seller.txt
${PIO_CMD} keys add feebucket --recover --keyring-backend test < ${MNEMONICS_DIR}/feebucket.txt
${PIO_CMD} keys add merchant --recover --keyring-backend test < ${MNEMONICS_DIR}/merchant.txt


export VALIDATOR_ID=$(${PIO_CMD} keys show -a validator )
echo "Validtor ${VALIDATOR_ID}"
export BUYER=$(${PIO_CMD} keys show -a buyer )
export SELLER=$(${PIO_CMD} keys show -a seller )
export FEEBUCKET=$(${PIO_CMD} keys show -a feebucket )

export ASSESS_FEE_NHASH='{"fee_amount":{"amount":"1000","denom":"nhash"},"fee_recipient":"'${FEEBUCKET}'"}'
export ASSESS_FEE_USD='{"fee_amount":{"amount":"70","denom":"usd"},"fee_recipient":"'${FEEBUCKET}'"}'

# Wasm Contract Storing and Initializing 

echo "Storing ${WASM_BIN_DIR}/msgfees.wasm"
${PIO_CMD} \
    tx wasm store ${WASM_BIN_DIR}/msgfees.wasm  \
    --from validator \
    ${COMMON_TX_FLAGS} | jq

echo "Initiating wasm contract id 1"
${PIO_CMD} \
    tx wasm instantiate 1 \
    ${ASSESS_FEE_NHASH}\
    --admin ${VALIDATOR_ID} \
    --label msgfees \
    --from validator \
    ${COMMON_TX_FLAGS} | jq

${PIO_CMD} \
    tx wasm instantiate 1 \
    ${ASSESS_FEE_USD} \
    --admin ${VALIDATOR_ID} \
    --label msgfees \
    --from validator \
    ${COMMON_TX_FLAGS} | jq

# ${PIO_CMD} \
#     tx wasm instantiate 1 \
#     '{"fee_amount":{"amount":"9999","denom":"jackthecat"},"fee_recipient":"'${BUYER}'"}' \
#     --admin ${VALIDATOR_ID} \
#     --label msgfees \
#     --from validator \
#     ${COMMON_TX_FLAGS} | jq