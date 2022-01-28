#!/bin/bash
PROVENANCE_DEV_DIR=~/code/provenance
COMMON_TX_FLAGS="--gas auto --gas-prices 1905nhash --gas-adjustment 2 --chain-id testing --keyring-backend test --yes -o json"
GENTX_FILE_NAME=${PROVENANCE_DEV_DIR}/generated.send1.json
GENTX_AUTHZ_FILE_NAME=${PROVENANCE_DEV_DIR}/authz.generated.send1.json

export VALIDATOR_ID=$(${PROVENANCE_DEV_DIR}/build/provenanced keys show -a validator --home ${PROVENANCE_DEV_DIR}/build/run/provenanced -t)
export BUYER=$(${PROVENANCE_DEV_DIR}/build/provenanced keys show -a buyer --home ${PROVENANCE_DEV_DIR}/build/run/provenanced -t)
export SELLER=$(${PROVENANCE_DEV_DIR}/build/provenanced keys show -a seller --home ${PROVENANCE_DEV_DIR}/build/run/provenanced -t)

# ${PIO_CMD} tx authz exec ${GENTX_FILE_NAME}  \
#     --from ${BUYER} --fees 100000000000nhash --chain-id testing --keyring-backend test --yes -o json --generate-only | jq > ${GENTX_AUTHZ_FILE_NAME}

# ${PIO_CMD} tx sign ${GENTX_AUTHZ_FILE_NAME} --chain-id testing --keyring-backend test --from ${BUYER} | jq > ${GENTX_AUTHZ_FILE_NAME}.signed

${PIO_CMD} tx authz exec ${GENTX_AUTHZ_FILE_NAME}.signed --from ${BUYER} --fees 130772535nhash --chain-id testing --keyring-backend test --yes -o json | jq