#!/bin/bash

# I'm using a provenance "run" instance for these tests
# provenance setup, clean project, make, adjust the voting period in the config to test msg based fee proposals: 
# 'make clean ; make build; make run-config; cat ./build/run/provenanced/config/genesis.json | jq '\'' .app_state.gov.voting_params.voting_period="20s" '\'' | tee ./build/run/provenanced/config/genesis.json; cat ./build/run/provenanced/config/genesis.json'

PROVENANCE_DEV_DIR=~/code/provenance
PROVENANCE_DEV_BUILD=build/provenanced
PIO_ENV_FLAGS="-t --home ${PROVENANCE_DEV_DIR}/build/run/provenanced"
PIO_CMD="${PROVENANCE_DEV_DIR}/${PROVENANCE_DEV_BUILD} ${PIO_ENV_FLAGS}"

MNEMONICS_DIR=~/code/pio-scratch/mnemonics
COMMON_TX_FLAGS="--gas auto --gas-prices 1905nhash --gas-adjustment 2 --chain-id testing --keyring-backend test --yes -o json"


######################################### SETUP FOR ATS CONTRACT EXECUTION ##############################################

${PIO_CMD} keys add buyer --recover --keyring-backend test < ${MNEMONICS_DIR}/buyer.txt
${PIO_CMD} keys add seller --recover --keyring-backend test < ${MNEMONICS_DIR}/seller.txt

VALIDATOR_ID=$(${PROVENANCE_DEV_DIR}/build/provenanced keys show -a validator --home ${PROVENANCE_DEV_DIR}/build/run/provenanced -t) 
BUYER=$(${PROVENANCE_DEV_DIR}/build/provenanced keys show -a buyer --home ${PROVENANCE_DEV_DIR}/build/run/provenanced -t) 
SELLER=$(${PROVENANCE_DEV_DIR}/build/provenanced keys show -a seller --home ${PROVENANCE_DEV_DIR}/build/run/provenanced -t) 

echo "Creating marker gme"

${PIO_CMD} \
     tx marker new 1000gme.local \
    --type COIN \
    --from validator \
    --fees 101000000000nhash \
    --chain-id testing --keyring-backend test --yes -o json | jq

echo "Grant marker gme"
${PIO_CMD} \
    tx marker grant ${VALIDATOR_ID} gme.local mint,burn,admin,withdraw,deposit \
    --from validator \
${COMMON_TX_FLAGS} | jq

echo "Finalize marker gme"
${PIO_CMD} \
     tx marker finalize gme.local \
    --from validator \
${COMMON_TX_FLAGS} | jq

echo "Activate marker gme"
${PIO_CMD} \
    tx marker activate gme.local \
    --from validator \
${COMMON_TX_FLAGS} | jq


echo "Creating marker usd"

${PIO_CMD} \
     tx marker new 1000usd.local \
    --type COIN \
    --from validator \
    --fees 101000000000nhash \
    --chain-id testing --keyring-backend test --yes -o json | jq

echo "Creating marker usd"
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
    --from validator \
    ${COMMON_TX_FLAGS} | jq

${PIO_CMD} tx marker withdraw usd.local 1000usd.local ${BUYER}  \
    --from validator \
    ${COMMON_TX_FLAGS} | jq

${PIO_CMD} tx bank send ${VALIDATOR_ID} ${SELLER} 100000000000nhash  \
    --from validator \
    ${COMMON_TX_FLAGS} | jq

${PIO_CMD} tx marker withdraw gme.local 1000gme.local ${SELLER}  \
    --from validator \
    ${COMMON_TX_FLAGS} | jq