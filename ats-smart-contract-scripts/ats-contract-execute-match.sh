#!/bin/bash
PROVENANCE_DEV_DIR=~/code/provenance
PROVENANCE_DEV_BUILD=build/provenanced
PIO_ENV_FLAGS="-t --home ${PROVENANCE_DEV_DIR}/build/run/provenanced"
PIO_CMD="${PROVENANCE_DEV_DIR}/${PROVENANCE_DEV_BUILD} ${PIO_ENV_FLAGS}"
COMMON_TX_FLAGS="--gas auto --gas-prices 1905nhash --gas-adjustment 2 --chain-id testing --keyring-backend test --yes -o json"

######################################### SETUP FOR ATS CONTRACT EXECUTION ##############################################

export VALIDATOR_ID=$(${PROVENANCE_DEV_DIR}/build/provenanced keys show -a validator --home ${PROVENANCE_DEV_DIR}/build/run/provenanced -t)
export BUYER=$(${PROVENANCE_DEV_DIR}/build/provenanced keys show -a buyer --home ${PROVENANCE_DEV_DIR}/build/run/provenanced -t)
export SELLER=$(${PROVENANCE_DEV_DIR}/build/provenanced keys show -a seller --home ${PROVENANCE_DEV_DIR}/build/run/provenanced -t)
export ATS_EX=$(${PIO_CMD} q name resolve ats-ex.pb --testnet | awk '{print $2}')

# echo ""
# echo "#############"
# echo "Show Balances Before Match"
# echo "#############"
# echo ""
# echo "Buyer: ${BUYER}"
# ${PIO_CMD} \
#     q bank balances ${BUYER}

# echo "Seller: ${SELLER}"
# ${PIO_CMD} \
#     q bank balances ${SELLER}

# echo "Match and execute orders..."
# ${PIO_CMD} \
#     tx wasm execute ${ATS_EX} \
#     '{"execute_match":{"ask_id":"02ee2ed1-939d-40ed-9e1b-bb96f76f0fca", "bid_id":"6a25ffc2-181e-4187-9ac6-572c17038277", "price":"2", "size": "500"}}' \
#     --from validator \
#     ${COMMON_TX_FLAGS} | jq

# echo ""
# echo "#############"
# echo "Show Balances After Match"
# echo "#############"
# echo ""
# echo "Buyer: ${BUYER}"
# ${PIO_CMD} \
#     q bank balances ${BUYER}

# echo "Seller: ${SELLER}"
# ${PIO_CMD} \
#     q bank balances ${SELLER}

echo "Match and execute orders..."
${PIO_CMD} \
    tx wasm execute ${ATS_EX} \
    '{"execute_match":{"ask_id":"02ee2ed1-939d-40ed-9e1b-bb96f76f0fca", "bid_id":"6a25ffc2-181e-4187-9ac6-572c17038277", "price":"2", "size": "500"}}' \
    --from ${VALIDATOR_ID} \
    --generate-only --chain-id testing --keyring-backend test | jq > generated.match.json

${PIO_CMD} \
    tx sign generated.match.json \
    --from ${VALIDATOR_ID} \
    --chain-id testing --keyring-backend test | jq > generated.match.json.signed