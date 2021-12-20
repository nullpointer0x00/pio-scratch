#!/bin/bash

PROVENANCE_DEV_DIR=~/code/provenance
MNEMONICS_DIR=~/code/pio-scratch/mnemonics
VOTING_PERIOD=5s

# clean and rebuild my provenance run environment
# also adjust the voting period to have faster proposal voting for development 
cd ${PROVENANCE_DEV_DIR}
echo "Building a clean run environment"
make clean 
make build 
make run-config 
echo "Changing voting period time to ${VOTING_PERIOD}"
cat ./build/run/provenanced/config/genesis.json | jq ' .app_state.gov.voting_params.voting_period="'${VOTING_PERIOD}'" ' | tee ./build/run/provenanced/config/genesis.json 
cat ./build/run/provenanced/config/genesis.json | grep voting

${PROVENANCE_DEV_DIR}/build/provenanced -t --home ${PROVENANCE_DEV_DIR}/build/run/provenanced keys add buyer --recover --keyring-backend test < ${MNEMONICS_DIR}/buyer.txt
${PROVENANCE_DEV_DIR}/build/provenanced -t --home ${PROVENANCE_DEV_DIR}/build/run/provenanced keys add seller --recover --keyring-backend test < ${MNEMONICS_DIR}/seller.txt