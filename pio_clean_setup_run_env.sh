#!/bin/bash

# Provenance Configuration
PROVENANCE_DEV_DIR=~/code/provenance
PROVENANCE_HOME=${PROVENANCE_DEV_DIR}/build/run/provenanced
CONFIG=run-config
VOTING_PERIOD=20s
MINUTE_EPOCH="{\"identifier\": \"minute\",\"start_height\": \"0\",\"duration\": \"12\",\"current_epoch\": \"0\", \"current_epoch_start_height\": \"0\",\"epoch_counting_started\": false}"

# clean and rebuild my provenance run environment
# also adjust the voting period to have faster proposal voting for development
cd ${PROVENANCE_DEV_DIR}
go mod vendor
make clean 
make build 
make ${CONFIG}
cat ${PROVENANCE_HOME}/config/genesis.json | jq ' .app_state.gov.voting_params.voting_period="'${VOTING_PERIOD}'" ' | tee ${PROVENANCE_HOME}/config/genesis.json 
#cat ${PROVENANCE_DEV_DIR}/build/run/provenanced/config/genesis.json | jq --arg minute_epoch "$MINUTE_EPOCH" ' .app_state.epoch.epochs += ['$'] ' | tee ${PROVENANCE_DEV_DIR}/build/run/provenanced/config/genesis.json
cat ${PROVENANCE_HOME}/config/genesis.json | grep voting
