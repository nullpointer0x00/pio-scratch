#!/bin/bash
PROVENANCE_DEV_DIR=~/code/provenance
VERSION_ID="green"
DESCRIPTION="upgrade-description"
TITLE="upgrade-title"
INFO="upgrade-info"
DEPOSIT=10000000000nhash
UPGRADE_HEIGHT=100
PROPOSAL_ID=1

echo "ADDING UPGRADE PROPOSAL"
${PROVENANCE_DEV_DIR}/build/provenanced tx gov submit-proposal software-upgrade "${VERSION_ID}" \
    --title "${TITLE}" \
    --description "${DESCRIPTION}" \
    --upgrade-info "${INFO}" \
    --upgrade-height ${UPGRADE_HEIGHT} \
    --deposit ${DEPOSIT} \
    --from validator \
    --yes -t --home ${PROVENANCE_DEV_DIR}/build/run/provenanced \
    --fees 1000000000nhash --chain-id testing --keyring-backend test -o json | jq
echo "VOTING ON PROPOSAL"
${PROVENANCE_DEV_DIR}/build/provenanced tx gov vote ${PROPOSAL_ID} yes --from validator --yes -t --home ${PROVENANCE_DEV_DIR}/build/run/provenanced --fees 1000000000nhash --chain-id testing --keyring-backend test -o json | jq