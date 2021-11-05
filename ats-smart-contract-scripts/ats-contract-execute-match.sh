#!/bin/bash
PROVENANCE_DEV_DIR=~/code/provenance
COMMON_TX_FLAGS="--gas auto --gas-prices 1905nhash --gas-adjustment 2 --chain-id testing --keyring-backend test --yes -o json"

######################################### SETUP FOR ATS CONTRACT EXECUTION ##############################################

export VALIDATOR_ID=$(${PROVENANCE_DEV_DIR}/build/provenanced keys show -a validator --home ${PROVENANCE_DEV_DIR}/build/run/provenanced -t)
export BUYER=$(${PROVENANCE_DEV_DIR}/build/provenanced keys show -a buyer --home ${PROVENANCE_DEV_DIR}/build/run/provenanced -t)
export SELLER=$(${PROVENANCE_DEV_DIR}/build/provenanced keys show -a seller --home ${PROVENANCE_DEV_DIR}/build/run/provenanced -t)
export ATS_EX=$(${PROVENANCE_DEV_DIR}/build/provenanced -t --home ${PROVENANCE_DEV_DIR}/build/run/provenanced q name resolve ats-ex.pb --testnet | awk '{print $2}')

echo ""
echo "#############"
echo "Show Balances Before"
echo "#############"
echo ""
echo "Buyer: ${BUYER}"
${PROVENANCE_DEV_DIR}/build/provenanced -t --home ${PROVENANCE_DEV_DIR}/build/run/provenanced \
    q bank balances ${BUYER}

echo "Seller: ${SELLER}"
${PROVENANCE_DEV_DIR}/build/provenanced -t --home ${PROVENANCE_DEV_DIR}/build/run/provenanced \
    q bank balances ${SELLER}

echo "Match and execute orders..."
${PROVENANCE_DEV_DIR}/build/provenanced -t --home ${PROVENANCE_DEV_DIR}/build/run/provenanced \
    tx wasm execute ${ATS_EX} \
    '{"execute_match":{"ask_id":"02ee2ed1-939d-40ed-9e1b-bb96f76f0fca", "bid_id":"6a25ffc2-181e-4187-9ac6-572c17038277", "price":"2", "size": "500"}}' \
    --from validator \
    ${COMMON_TX_FLAGS} | jq

echo ""
echo "#############"
echo "Show Balances After"
echo "#############"
echo ""
echo "Buyer: ${BUYER}"
${PROVENANCE_DEV_DIR}/build/provenanced -t --home ${PROVENANCE_DEV_DIR}/build/run/provenanced \
    q bank balances ${BUYER}

echo "Seller: ${SELLER}"
${PROVENANCE_DEV_DIR}/build/provenanced -t --home ${PROVENANCE_DEV_DIR}/build/run/provenanced \
    q bank balances ${SELLER}