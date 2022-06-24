#!/bin/bash
PROVENANCE_DEV_DIR=~/code/provenance
PIO_SCRATCH_DIR=~/code/pio-scratch
VOTING_PERIOD=300s
MINUTE_EPOCH="{\"identifier\": \"minute\",\"start_height\": \"0\",\"duration\": \"12\",\"current_epoch\": \"0\", \"current_epoch_start_height\": \"0\",\"epoch_counting_started\": false}"
MNEMONICS_DIR=mnemonics

# clean and rebuild my provenance run environment
# also adjust the voting period to have faster proposal voting for development 
cd ${PROVENANCE_DEV_DIR}
go mod vendor
make clean 
make build 
make run-config 
${PROVENANCE_DEV_DIR}/build/provenanced keys add buyer --recover --keyring-backend test < ${PIO_SCRATCH_DIR}/${MNEMONICS_DIR}/buyer.txt
${PROVENANCE_DEV_DIR}/build/provenanced keys add seller --recover --keyring-backend test < ${PIO_SCRATCH_DIR}/${MNEMONICS_DIR}/seller.txt

cat ${PIO_SCRATCH_DIR}/genesis-setup.json > ${PROVENANCE_DEV_DIR}/build/run/provenanced/config/genesis.json
cat ${PROVENANCE_DEV_DIR}/build/run/provenanced/config/genesis.json | jq
cat  ${PIO_SCRATCH_DIR}/${MNEMONICS_DIR}/seller.txt
# ${PROVENANCE_DEV_DIR}/build/provenanced keys add buyer --recover --keyring-backend test < ${PIO_SCRATCH_DIR}/${MNEMONICS_DIR}/buyer.txt
# ${PROVENANCE_DEV_DIR}/build/provenanced keys add seller --recover --keyring-backend test < ${PIO_SCRATCH_DIR}/${MNEMONICS_DIR}/seller.txt