#!/bin/bash

# I'm using a provenance "run" instance for these tests
# provenance setup, clean project, make, adjust the voting period in the config to test msg based fee proposals: 
# 'make clean ; make build; make run-config; cat ./build/run/provenanced/config/genesis.json | jq '\'' .app_state.gov.voting_params.voting_period="20s" '\'' | tee ./build/run/provenanced/config/genesis.json; cat ./build/run/provenanced/config/genesis.json'

PROVENANCE_DEV_DIR=~/code/provenance
COMMON_TX_FLAGS="--gas auto --gas-prices 1905nhash --gas-adjustment 2 --chain-id testing --keyring-backend test --yes -o json"

######################################### SETUP FOR ATS CONTRACT EXECUTION ##############################################

${PIO_CMD} keys add buyer --recover --keyring-backend test < ./mnemonics/buyer.txt
${PIO_CMD} keys add seller --recover --keyring-backend test < ./mnemonics/seller.txt

export VALIDATOR_ID=$(${PROVENANCE_DEV_DIR}/build/provenanced keys show -a validator --home ${PROVENANCE_DEV_DIR}/build/run/provenanced -t)
export BUYER=$(${PROVENANCE_DEV_DIR}/build/provenanced keys show -a buyer --home ${PROVENANCE_DEV_DIR}/build/run/provenanced -t)
export SELLER=$(${PROVENANCE_DEV_DIR}/build/provenanced keys show -a seller --home ${PROVENANCE_DEV_DIR}/build/run/provenanced -t)

echo "Creating marker gme"

${PIO_CMD} \
     tx marker new 1000gme.local \
    --type COIN \
    --from validator \
    ${COMMON_TX_FLAGS} | jq

${PIO_CMD} \
    tx marker grant ${VALIDATOR_ID} gme.local mint,burn,admin,withdraw,deposit \
    --from validator \
${COMMON_TX_FLAGS} | jq

${PIO_CMD} \
     tx marker finalize gme.local \
    --from validator \
${COMMON_TX_FLAGS} | jq

${PIO_CMD} \
    tx marker activate gme.local \
    --from validator \
${COMMON_TX_FLAGS} | jq


echo "Creating marker usd"

${PIO_CMD} \
     tx marker new 1000usd.local \
    --type COIN \
    --from validator \
    ${COMMON_TX_FLAGS} | jq

${PIO_CMD} \
    tx marker grant ${VALIDATOR_ID} usd.local mint,burn,admin,withdraw,deposit \
    --from validator \
    ${COMMON_TX_FLAGS} | jq

${PIO_CMD} \
     tx marker finalize usd.local \
    --from validator \
    ${COMMON_TX_FLAGS} | jq

${PIO_CMD} \
    tx marker activate usd.local \
    --from validator \
    ${COMMON_TX_FLAGS} | jq

# FUNDING ACCOUNTS STUFF
# 
# 
echo "Funding all accounts"
${PIO_CMD} tx bank send ${VALIDATOR_ID} ${BUYER} 100000000000nhash  \
    --from validator --fees 100000000000nhash --chain-id testing --keyring-backend test --yes -o json | jq

${PIO_CMD} tx marker withdraw usd.local 1000usd.local ${BUYER}  \
    --from validator --fees 10000000000nhash --chain-id testing --keyring-backend test --yes -o json | jq

${PIO_CMD} tx bank send ${VALIDATOR_ID} ${SELLER} 100000000000nhash  \
    --from validator --fees 1000000000nhash --chain-id testing --keyring-backend test --yes -o json | jq

${PIO_CMD} tx marker withdraw gme.local 1000gme.local ${SELLER}  \
    --from validator --fees 1000000000nhash --chain-id testing --keyring-backend test --yes -o json| jq

######################################### DONE WITH SETUP FOR ATS CONTRACT EXECUTION ##############################################

# Wasm Contract Stuff
# This is the important stuff...everything else before this was setup for the main event
# 
echo "Storing, instantiating, and executing ats contract"
${PIO_CMD} \
    tx wasm store wasms/ats_smart_contract.wasm  \
    --from validator \
    ${COMMON_TX_FLAGS} | jq


${PIO_CMD} \
    tx wasm instantiate 1 \
    '{"name":"ats-ex", "bind_name":"ats-ex.pb", "base_denom":"gme.local", "convertible_base_denoms":[], "supported_quote_denoms":["usd.local"], "approvers":[], "executors":["'${VALIDATOR_ID}'"], "ask_required_attributes":[], "bid_required_attributes":[], "price_precision": "0", "size_increment": "1"}' \
    --admin ${VALIDATOR_ID} \
    --label ats-ex \
    --from validator \
    ${COMMON_TX_FLAGS} | jq
export ATS_EX=$(${PIO_CMD} q name resolve ats-ex.pb --testnet | awk '{print $2}')

echo "Ats instantiated id is ${ATS_EX}"

### WASM EXECUTES ###
echo "Creating an ask..."
${PIO_CMD} \
    tx wasm execute ${ATS_EX} \
    '{"create_ask":{"id":"02ee2ed1-939d-40ed-9e1b-bb96f76f0fca", "base":"gme.local", "quote":"usd.local", "price": "2", "size":"500"}}' \
    --amount 500gme.local \
    --from seller \
    ${COMMON_TX_FLAGS} | jq

echo "Creating a bid..."
${PIO_CMD} \
    tx wasm execute ${ATS_EX} \
    '{"create_bid":{"id":"6a25ffc2-181e-4187-9ac6-572c17038277", "base":"gme.local", "price": "2", "quote":"usd.local", "quote_size":"1000", "size":"500"}}' \
    --amount 1000usd.local \
    --from buyer \
    ${COMMON_TX_FLAGS} | jq

echo "Match and execute orders..."
${PIO_CMD} \
    tx wasm execute ${ATS_EX} \
    '{"execute_match":{"ask_id":"02ee2ed1-939d-40ed-9e1b-bb96f76f0fca", "bid_id":"6a25ffc2-181e-4187-9ac6-572c17038277", "price":"2", "size": "500"}}' \
    --from validator \
    ${COMMON_TX_FLAGS} | jq

echo ""
echo "#############"
echo "Show Balances"
echo "#############"
echo ""
${PIO_CMD} \
    q bank balances ${BUYER}

${PIO_CMD} \
    q bank balances ${SELLER}