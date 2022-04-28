#!/bin/bash

PROVENANCE_DEV_DIR=~/code/provenance
PROVENANCE_DEV_BUILD=build/provenanced
PIO_ENV_FLAGS="-t --home ${PROVENANCE_DEV_DIR}/build/run/provenanced"
PIO_CMD="${PROVENANCE_DEV_DIR}/${PROVENANCE_DEV_BUILD} ${PIO_ENV_FLAGS}"

VALIDATOR_ID=$(${PROVENANCE_DEV_DIR}/build/provenanced keys show -a validator --home ${PROVENANCE_DEV_DIR}/build/run/provenanced -t)
BUYER=$(${PROVENANCE_DEV_DIR}/build/provenanced keys show -a buyer --home ${PROVENANCE_DEV_DIR}/build/run/provenanced -t)
SELLER=$(${PROVENANCE_DEV_DIR}/build/provenanced keys show -a seller --home ${PROVENANCE_DEV_DIR}/build/run/provenanced -t)

DELEGATOR_ADDR=$(${PROVENANCE_DEV_DIR}/build/provenanced -t --home ${PROVENANCE_DEV_DIR}/build/run/provenanced q staking validators -o json | jq -r '.validators[0].operator_address')
echo ${DELEGATOR_ADDR}

${PROVENANCE_DEV_DIR}/build/provenanced -t --home ${PROVENANCE_DEV_DIR}/build/run/provenanced tx staking delegate ${DELEGATOR_ADDR} 1000000000000nhash --from buyer --yes --gas auto --gas-prices 1905nhash --gas-adjustment 2 --chain-id testing --keyring-backend test -o json | jq
${PROVENANCE_DEV_DIR}/build/provenanced -t --home ${PROVENANCE_DEV_DIR}/build/run/provenanced tx staking delegate ${DELEGATOR_ADDR} 1000000000000nhash --from buyer --yes --gas auto --gas-prices 1905nhash --gas-adjustment 2 --chain-id testing --keyring-backend test -o json | jq
#sleep 60
${PROVENANCE_DEV_DIR}/build/provenanced -t --home ${PROVENANCE_DEV_DIR}/build/run/provenanced tx staking delegate ${DELEGATOR_ADDR} 1000000000000nhash --from buyer --yes --gas auto --gas-prices 1905nhash --gas-adjustment 2 --chain-id testing --keyring-backend test -o json | jq
${PROVENANCE_DEV_DIR}/build/provenanced -t --home ${PROVENANCE_DEV_DIR}/build/run/provenanced tx staking delegate ${DELEGATOR_ADDR} 1000000000000nhash --from buyer --yes --gas auto --gas-prices 1905nhash --gas-adjustment 2 --chain-id testing --keyring-backend test -o json | jq
#sleep 60
${PROVENANCE_DEV_DIR}/build/provenanced -t --home ${PROVENANCE_DEV_DIR}/build/run/provenanced tx staking delegate ${DELEGATOR_ADDR} 1000000000000nhash --from buyer --yes --gas auto --gas-prices 1905nhash --gas-adjustment 2 --chain-id testing --keyring-backend test -o json | jq 
${PROVENANCE_DEV_DIR}/build/provenanced -t --home ${PROVENANCE_DEV_DIR}/build/run/provenanced tx staking delegate ${DELEGATOR_ADDR} 1000000000000nhash --from buyer --yes --gas auto --gas-prices 1905nhash --gas-adjustment 2 --chain-id testing --keyring-backend test -o json | jq
#sleep 60
${PROVENANCE_DEV_DIR}/build/provenanced -t --home ${PROVENANCE_DEV_DIR}/build/run/provenanced tx staking delegate ${DELEGATOR_ADDR} 1000000000000nhash --from buyer --yes --gas auto --gas-prices 1905nhash --gas-adjustment 2 --chain-id testing --keyring-backend test -o json | jq
${PROVENANCE_DEV_DIR}/build/provenanced -t --home ${PROVENANCE_DEV_DIR}/build/run/provenanced tx staking delegate ${DELEGATOR_ADDR} 1000000000000nhash --from buyer --yes --gas auto --gas-prices 1905nhash --gas-adjustment 2 --chain-id testing --keyring-backend test -o json | jq
#sleep 60
${PROVENANCE_DEV_DIR}/build/provenanced -t --home ${PROVENANCE_DEV_DIR}/build/run/provenanced tx staking delegate ${DELEGATOR_ADDR} 1000000000000nhash --from buyer --yes --gas auto --gas-prices 1905nhash --gas-adjustment 2 --chain-id testing --keyring-backend test -o json | jq
${PROVENANCE_DEV_DIR}/build/provenanced -t --home ${PROVENANCE_DEV_DIR}/build/run/provenanced tx staking delegate ${DELEGATOR_ADDR} 1000000000000nhash --from buyer --yes --gas auto --gas-prices 1905nhash --gas-adjustment 2 --chain-id testing --keyring-backend test -o json | jq
#sleep 60
${PROVENANCE_DEV_DIR}/build/provenanced -t --home ${PROVENANCE_DEV_DIR}/build/run/provenanced tx staking delegate ${DELEGATOR_ADDR} 1000000000000nhash --from buyer --yes --gas auto --gas-prices 1905nhash --gas-adjustment 2 --chain-id testing --keyring-backend test -o json | jq
${PROVENANCE_DEV_DIR}/build/provenanced -t --home ${PROVENANCE_DEV_DIR}/build/run/provenanced tx staking delegate ${DELEGATOR_ADDR} 1000000000000nhash --from buyer --yes --gas auto --gas-prices 1905nhash --gas-adjustment 2 --chain-id testing --keyring-backend test -o json | jq
#sleep 60
${PROVENANCE_DEV_DIR}/build/provenanced -t --home ${PROVENANCE_DEV_DIR}/build/run/provenanced tx staking delegate ${DELEGATOR_ADDR} 1000000000000nhash --from buyer --yes --gas auto --gas-prices 1905nhash --gas-adjustment 2 --chain-id testing --keyring-backend test -o json | jq
${PROVENANCE_DEV_DIR}/build/provenanced -t --home ${PROVENANCE_DEV_DIR}/build/run/provenanced tx staking delegate ${DELEGATOR_ADDR} 1000000000000nhash --from buyer --yes --gas auto --gas-prices 1905nhash --gas-adjustment 2 --chain-id testing --keyring-backend test -o json | jq
#sleep 60