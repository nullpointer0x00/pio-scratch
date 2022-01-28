#!/bin/bash
PROVENANCE_DEV_DIR=~/code/provenance
VOTING_PERIOD=5s

# clean and rebuild my provenance run environment
# also adjust the voting period to have faster proposal voting for development 
cd ${PROVENANCE_DEV_DIR}
go mod vendor
make clean 
make build 
make run-config 
cat ./build/run/provenanced/config/genesis.json | jq ' .app_state.gov.voting_params.voting_period="'${VOTING_PERIOD}'" ' | tee ./build/run/provenanced/config/genesis.json 
cat ./build/run/provenanced/config/genesis.json | grep voting