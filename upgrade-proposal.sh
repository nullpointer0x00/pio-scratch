#!/bin/bash

# Provenance Configuration
PROVENANCE_DEV_DIR=~/code/provenance
PROVENANCE_DEV_BUILD=${PROVENANCE_DEV_DIR}/build/provenanced
PROVENANCE_HOME=${PROVENANCE_DEV_DIR}/build/run/provenanced
CHAIN_ID=testing

# Upgrade Configuration
VERSION_ID="ochre-rc1"
DESCRIPTION="upgrade-description"
TITLE="upgrade-title"
INFO="upgrade info"
DEPOSIT=100100000000000nhash
UPGRADE_HEIGHT=50
PROPOSAL_ID=1
PROPOSAL_CMD=submit-proposal

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


# provenanced tx gov submit-proposal software-upgrade "mango" \
#     --title "mango - v1.11.1-rc1" \
#     --description "mango upgrade for software upgrade v1.11.1-rc1" \
#     --upgrade-info "https://github.com/provenance-io/provenance/releases/download/v1.11.1-rc1/plan-v1.11.1-rc1.json" \
#     --upgrade-height ${UPGRADE_HEIGHT} \
#     --deposit ${DEPOSIT} 

# provenanced tx gov submit-proposal software-upgrade "mango-rc2" \
#     --title "mango-rc2 - v1.11.1-rc2" \
#     --description "mango-rc2 upgrade for software upgrade v1.11.1-rc2" \
#     --upgrade-info "https://github.com/provenance-io/provenance/releases/download/v1.11.1-rc2/plan-v1.11.1-rc2.json" \
#     --upgrade-height 8740707 \
#     --deposit 50000000000000nhash 
