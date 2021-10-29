#!/bin/bash
PROVENANCE_DEV_DIR=~/code/provenance
VOTING_PERIOD=21s

# clean and rebuild my provenance run environment
# also adjust the voting period to have faster proposal voting for development 
cd ${PROVENANCE_DEV_DIR}
make clean 
make build 
make run-config 
cat ./build/run/provenanced/config/genesis.json | jq ' .app_state.gov.voting_params.voting_period="'${VOTING_PERIOD}'" ' | tee ./build/run/provenanced/config/genesis.json 
cat ./build/run/provenanced/config/genesis.json | grep voting