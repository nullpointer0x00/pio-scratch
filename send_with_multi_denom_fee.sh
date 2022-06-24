#!/bin/bash
SEND_AMOUNT_1=1usd.local
COMMON_TX_FLAGS="--gas auto --gas-prices 1905nhash --gas-adjustment 2 --chain-id testing --keyring-backend test --yes -o json"

PROVENANCE_DEV_DIR=~/code/provenance
PROVENANCE_DEV_BUILD=build/provenanced
PIO_ENV_FLAGS="-t --home ${PROVENANCE_DEV_DIR}/build/run/provenanced"
PIO_CMD="${PROVENANCE_DEV_DIR}/${PROVENANCE_DEV_BUILD} ${PIO_ENV_FLAGS}"

export VALIDATOR_ID=$(${PROVENANCE_DEV_DIR}/build/provenanced keys show -a validator --home ${PROVENANCE_DEV_DIR}/build/run/provenanced -t)
export BUYER=$(${PROVENANCE_DEV_DIR}/build/provenanced keys show -a buyer --home ${PROVENANCE_DEV_DIR}/build/run/provenanced -t)
export SELLER=$(${PROVENANCE_DEV_DIR}/build/provenanced keys show -a seller --home ${PROVENANCE_DEV_DIR}/build/run/provenanced -t)

echo "Balances before send..."
${PIO_CMD} q bank balances ${VALIDATOR_ID} -o json | jq
echo "Rewards before send..."
${PIO_CMD} query distribution rewards ${VALIDATOR_ID} -o json | jq
# ${PIO_CMD} q bank balances ${BUYER} -o json | jq
# ${PIO_CMD} q bank balances ${SELLER} -o json | jq

echo "Sending some usd.local to validator address and fee with multi denom"
${PIO_CMD} tx bank send ${BUYER} ${VALIDATOR_ID} ${SEND_AMOUNT_1}  \
    --from validator --fees 100000000000nhash,10usd.local --chain-id testing --keyring-backend test --yes -o json  | jq 

echo "Balances after send..."
${PIO_CMD} q bank balances ${VALIDATOR_ID} -o json | jq
echo "Rewards after send..."
${PIO_CMD} q distribution rewards ${VALIDATOR_ID} -o json | jq

# echo "Buyer Balance before send #2"
# ${PIO_CMD} q bank balances ${BUYER} -o json | jq
# echo "Sending some usd.local to validator address and fee with multi denom #2"
# ${PIO_CMD} tx bank send ${BUYER} ${VALIDATOR_ID} ${SEND_AMOUNT_1}  \
#     --from validator --fees 100000000000nhash,10usd.local --chain-id testing --keyring-backend test --yes -o json  | jq 

# echo "Balances after send #2..."
# ${PIO_CMD} q bank balances ${VALIDATOR_ID} -o json | jq
# echo "Rewards after send #2..."
# ${PIO_CMD} q distribution rewards ${VALIDATOR_ID} -o json | jq

echo "Withdraw All rewards"
${PIO_CMD} tx distribution withdraw-all-rewards --from ${VALIDATOR_ID}  \
    --from validator --fees 100000000000nhash --chain-id testing --keyring-backend test --yes -o json | jq

echo "Balances after rewards withdraw..."
${PIO_CMD} q bank balances ${VALIDATOR_ID} -o json | jq
echo "Rewards after rewards withdraw..."
${PIO_CMD} query distribution rewards ${VALIDATOR_ID} -o json | jq