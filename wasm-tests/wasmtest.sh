#!/bin/bash
PROVENANCE_DEV_DIR=~/code/provenance
PROVENANCE_DEV_BUILD=build/provenanced
PIO_ENV_FLAGS="-t --home ${PROVENANCE_DEV_DIR}/build/run/provenanced"
PIO_CMD="${PROVENANCE_DEV_DIR}/${PROVENANCE_DEV_BUILD} ${PIO_ENV_FLAGS}"
WASM_BIN_DIR=~/code/pio-scratch/wasms
COMMON_TX_FLAGS="--gas auto --gas-prices 1905nhash --gas-adjustment 2 --chain-id testing --keyring-backend test --yes -o json"

######################################### SETUP FOR ATS CONTRACT EXECUTION ##############################################

export VALIDATOR_ID=$(${PROVENANCE_DEV_DIR}/build/provenanced keys show -a validator --home ${PROVENANCE_DEV_DIR}/build/run/provenanced -t)
export BUYER=$(${PROVENANCE_DEV_DIR}/build/provenanced keys show -a buyer --home ${PROVENANCE_DEV_DIR}/build/run/provenanced -t)

# Wasm Contract Storing and Initializing 

echo "Storing ${WASM_BIN_DIR}/hackatom.wasm"
${PIO_CMD} \
    tx wasm store ${WASM_BIN_DIR}/hackatom.wasm  \
    --from validator \
    ${COMMON_TX_FLAGS} | jq

echo "Initiating wasm contract id 1"
INIT_CMD="{\"verifier\":\"${VALIDATOR_ID}\", \"beneficiary\":\"${BUYER}\"}"
${PIO_CMD} \
    tx wasm instantiate 1 \
    "${INIT_CMD}" \
    --admin ${VALIDATOR_ID} \
    --label "local0.1.0" \
    --from validator \
    ${COMMON_TX_FLAGS} | jq

CONTRACT=$(${PIO_CMD} query wasm list-contract-by-code 1 -o json | jq -r '.contracts[-1]')
echo "* Contract address: $CONTRACT"
echo "### Query all"
RESP=$(${PIO_CMD} query wasm contract-state all "$CONTRACT" -o json)
echo "$RESP" | jq
echo "### Query smart"
${PIO_CMD} query wasm contract-state smart "$CONTRACT" '{"verifier":{}}' -o json | jq
echo "### Query raw"
KEY=$(echo "$RESP" | jq -r ".models[0].key")
${PIO_CMD} query wasm contract-state raw "$CONTRACT" "$KEY" -o json | jq

echo "Funding contract account for releasing funds"
${PIO_CMD} tx bank send ${VALIDATOR_ID} ${CONTRACT} 100000000000nhash  \
    --from validator --fees 100000000000nhash --chain-id testing --keyring-backend test --yes -o json | jq

echo "Query balances of contract that will be released when executed.  With submsg BankSend"
${PIO_CMD} q bank balances ${CONTRACT} -o json | jq

echo "Executing wasm contract id ${CONTRACT} NOTE: if BankSend msgfees is added fees flag will need some tinkering"
MSG="{\"release\":{}}"
${PIO_CMD} \
    tx wasm execute ${CONTRACT} \
    "${MSG}" \
    --from validator \
  --fees 3000000000nhash --chain-id testing --keyring-backend test --yes -o json |jq
  #  ${COMMON_TX_FLAGS} | jq