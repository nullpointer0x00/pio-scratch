#!/bin/bash
PROVENANCE_DEV_DIR=~/code/provenance

SEND_AMOUNT_1=10nhash

export VALIDATOR_ID=$(${PROVENANCE_DEV_DIR}/build/provenanced keys show -a validator --home ${PROVENANCE_DEV_DIR}/build/run/provenanced -t)
export BUYER=$(${PROVENANCE_DEV_DIR}/build/provenanced keys show -a buyer --home ${PROVENANCE_DEV_DIR}/build/run/provenanced -t)
export SELLER=$(${PROVENANCE_DEV_DIR}/build/provenanced keys show -a seller --home ${PROVENANCE_DEV_DIR}/build/run/provenanced -t)

${PIO_CMD} tx bank send ${VALIDATOR_ID} ${BUYER} ${SEND_AMOUNT_1}  \
    --from ${VALIDATOR_ID} --fees 100000000000nhash --chain-id testing --keyring-backend test --yes -o json --generate-only | jq > generated.send1.json