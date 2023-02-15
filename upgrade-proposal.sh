#!/bin/bash

# Provenance Configuration
PROVENANCE_DEV_DIR=~/code/provenance
PROVENANCE_DEV_BUILD=${PROVENANCE_DEV_DIR}/build/provenanced
PROVENANCE_HOME=${PROVENANCE_DEV_DIR}/build/run/provenanced
CHAIN_ID=testing

# Upgrade Configuration
VERSION_ID="paua-rc1"
DESCRIPTION="upgrade-description"
TITLE="upgrade-title"
INFO="upgrade info"
DEPOSIT=100100000000000nhash
UPGRADE_HEIGHT=50
PROPOSAL_ID=1
PROPOSAL_CMD=submit-legacy-proposal


PROPOSAL_ID=$($PROVENANCE_BIN -t --home $PROVENANCE_HOME q gov proposals | grep "id:" | wc -l | sed 's/ //g')
PROPOSAL_ID=$(echo $(( $PROPOSAL_ID + 1 )))

echo "ADDING UPGRADE PROPOSAL"
${PROVENANCE_DEV_BUILD} tx gov ${PROPOSAL_CMD} software-upgrade "${VERSION_ID}" \
    --title "${TITLE}" \
    --description "${DESCRIPTION}" \
    --upgrade-info "${INFO}" \
    --upgrade-height ${UPGRADE_HEIGHT} \
    --deposit ${DEPOSIT} \
    --from validator \
    --yes -t --home ${PROVENANCE_HOME} \
    --fees 10000000000000nhash --chain-id ${CHAIN_ID} --keyring-backend test -o json | jq

echo "VOTING ON PROPOSAL"
${PROVENANCE_DEV_BUILD} tx gov vote ${PROPOSAL_ID} yes --from validator --yes -t --home ${PROVENANCE_HOME} --fees 10000000000000nhash --chain-id ${CHAIN_ID} --keyring-backend test -o json | jq

