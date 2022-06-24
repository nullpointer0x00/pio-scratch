#!/bin/bash

# Test runs the cosmwasm hackatom.wasm v0.22.0 file. 
# (https://github.com/CosmWasm/wasmd/blob/v0.22.0/x/wasm/keeper/testdata/hackatom.wasm)
# 
# 1) if CODE_ID is not set it will store and init the contract
# 2) the contract's account will be sent funds
# 3) the contract will be executed with the release directive
# 4) all funds should be drained from the contracts balances
#


PROVENANCE_DEV_DIR=~/code/provenance
PROVENANCE_DEV_BUILD=build/provenanced
PIO_ENV_FLAGS="-t --home ${PROVENANCE_DEV_DIR}/build/run/provenanced"
PIO_CMD="${PROVENANCE_DEV_DIR}/${PROVENANCE_DEV_BUILD} ${PIO_ENV_FLAGS}"
WASM_BIN_DIR=~/code/pio-scratch/wasms
COMMON_TX_FLAGS="--chain-id testing --keyring-backend test --yes -o json"
GAS_ADJUSTMENT_FLAGS="--gas auto --gas-prices 1905nhash --gas-adjustment 2"

EXECUTE_FEE=3000000000nhash

# if code id is set.  It will skip storing and init the contract
CODE_ID=1

# NOTE: to initialize these accounts ../pio_env_setup.sh is a good reference
export VALIDATOR_ID=$(${PROVENANCE_DEV_DIR}/build/provenanced keys show -a validator --home ${PROVENANCE_DEV_DIR}/build/run/provenanced -t)
export BUYER=$(${PROVENANCE_DEV_DIR}/build/provenanced keys show -a buyer --home ${PROVENANCE_DEV_DIR}/build/run/provenanced -t)

#Check if code id is set...if not store and init the contract
if [ -z $CODE_ID ] 
then
    # Wasm Contract Storing and Initializing 

    echo "Storing ${WASM_BIN_DIR}/hackatom.wasm"
    RESP=$(${PIO_CMD} \
        tx wasm store ${WASM_BIN_DIR}/hackatom.wasm  \
        --from validator \
        --fees 5000000000nhash \
        --gas 2000000 \
        ${COMMON_TX_FLAGS})

    # echo ${RESP} | jq

    CODE_ID=$(echo ${RESP} | jq -r '.logs[0].events[1].attributes[-1].value')
    if [ -z $CODE_ID ] 
    then 
        echo "Contract code missing. "
        exit 1
    fi 
    
    echo "Initiating wasm contract id ${CODE_ID}"
    INIT_CMD="{\"verifier\":\"${VALIDATOR_ID}\", \"beneficiary\":\"${BUYER}\"}"
    RESP=$(${PIO_CMD} \
        tx wasm instantiate ${CODE_ID} \
        "${INIT_CMD}" \
        --admin ${VALIDATOR_ID} \
        --label "local0.1.0" \
        --from validator \
        --fees 400000000nhash \
        --gas 200000 \
        ${COMMON_TX_FLAGS})
    # echo ${RESP} | jq
fi


CONTRACT=$(${PIO_CMD} query wasm list-contract-by-code ${CODE_ID} -o json | jq -r '.contracts[-1]')
if [ -z $CONTRACT ] || [ $CONTRACT = "null" ] 
then 
    echo "Contract id not found for contract code id: ${CODE_ID}"
    exit 1
fi 

echo "Funding contract account for releasing funds"
RESP=$(${PIO_CMD} tx bank send ${VALIDATOR_ID} ${CONTRACT} 100000000000nhash  \
    --from validator --fees 100000000000nhash --chain-id testing --keyring-backend test --yes -o json)

echo "Contract ${CONTRACT} before execution balances: "
${PIO_CMD} q bank balances ${CONTRACT} -o json | jq 

echo "Executing wasm contract id ${CONTRACT}"
echo "NOTE: if BankSend msgfees is added fees flag will need some tinkering"
MSG="{\"release\":{}}"
RESP=$(${PIO_CMD} \
    tx wasm execute ${CONTRACT} \
    "${MSG}" \
    --from validator \
  --fees ${EXECUTE_FEE} --chain-id testing --keyring-backend test --yes -o json | jq)
echo "Done executing contract."
# echo ${RESP} | jq

echo "Contract ${CONTRACT} final balances (should be empty) : "
${PIO_CMD} q bank balances ${CONTRACT} -o json | jq 
