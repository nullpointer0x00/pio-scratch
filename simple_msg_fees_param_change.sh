#!/bin/bash
PROVENANCE_DEV_DIR=~/code/provenance
PROPOSAL_LOCATION=~/code/pio-scratch/json/
PROPOSAL_ID=1

echo "ADDING PROPOSAL RIGHT NOW"
${PROVENANCE_DEV_DIR}/build/provenanced tx gov submit-proposal param-change ${PROPOSAL_LOCATION}msg-fees-param-change-proposal.json --from validator --yes -t --home ${PROVENANCE_DEV_DIR}/build/run/provenanced --fees 1000000000nhash --chain-id testing --keyring-backend test -o json | jq
echo "VOTING ON PROPOSAL"
${PROVENANCE_DEV_DIR}/build/provenanced tx gov vote ${PROPOSAL_ID} yes --from validator --yes -t --home ${PROVENANCE_DEV_DIR}/build/run/provenanced --fees 1000000000nhash --chain-id testing --keyring-backend test -o json | jq
echo "AFTER VOTING"