#!/bin/bash

# Provenance Configuration
PROVENANCE_DEV_DIR=~/code/provenance
SCRIPTS_DIR=~/code/pio-scratch
CHAIN_ID=testing
GAS_PRICE=1905nhash
GAS_ADJUSTMENT=1.5

# Environment
PROVENANCE_DEV_BUILD=${PROVENANCE_DEV_DIR}/build/provenanced
PROVENANCE_HOME=${PROVENANCE_DEV_DIR}/build/run/provenanced

# Commands
PIO_ENV_FLAGS="-t --home ${PROVENANCE_HOME}"
PIO_CMD="${PROVENANCE_DEV_BUILD} ${PIO_ENV_FLAGS}"

provenance() {
    CMD="$PIO_CMD $@"
    echo $CMD >&2
    $CMD
}

query() {
    provenance q "$@"
}

transaction() {
    provenance tx "$@" --gas auto --gas-prices $GAS_PRICE  --gas-adjustment $GAS_ADJUSTMENT --chain-id "$CHAIN_ID" -y
}

keys() {
    provenance keys "$@"
}