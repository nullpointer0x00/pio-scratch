#!/bin/bash
PROVENANCE_DEV_DIR=~/code/provenance
SEND_AMOUNT_1=1usd.local
COMMON_TX_FLAGS="--gas auto --gas-prices 1905nhash --gas-adjustment 2 --chain-id testing --keyring-backend test --yes -o json"

export VALIDATOR_ID=$(${PROVENANCE_DEV_DIR}/build/provenanced keys show -a validator --home ${PROVENANCE_DEV_DIR}/build/run/provenanced -t)
export BUYER=$(${PROVENANCE_DEV_DIR}/build/provenanced keys show -a buyer --home ${PROVENANCE_DEV_DIR}/build/run/provenanced -t)
export SELLER=$(${PROVENANCE_DEV_DIR}/build/provenanced keys show -a seller --home ${PROVENANCE_DEV_DIR}/build/run/provenanced -t)

${PIO_CMD} tx authz grant ${BUYER} send --spend-limit=100000000000nhash  \
    --from ${VALIDATOR_ID} --fees 100000000000nhash --chain-id testing --keyring-backend test --yes -o json  | jq 