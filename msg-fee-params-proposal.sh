#!/bin/bash
PROVENANCE_DEV_DIR=~/code/provenance
VERSION_ID="mango"
DESCRIPTION="upgrade-description"
TITLE="upgrade-title"
INFO="upgrade-info"
DEPOSIT=100100000000000nhash
UPGRADE_HEIGHT=50
PROPOSAL_ID=2

echo "ADDING UPGRADE PROPOSAL"
${PROVENANCE_DEV_DIR}/build/provenanced tx msgfees nhash-per-usd-mil \
"Change nhash-per-usd-mil param to 25,000,000nhash" \
"Change nhash-per-usd-mil param to 25,000,000nhash.  This will be the conversion rate of $0.040 for 1 hash" \
25000000 \
${DEPOSIT} \
    --from validator \
    --yes -t --home ${PROVENANCE_DEV_DIR}/build/run/provenanced \
    --fees 10000000000000nhash --chain-id testing --keyring-backend test -o json | jq
echo "VOTING ON PROPOSAL"
${PROVENANCE_DEV_DIR}/build/provenanced tx gov vote ${PROPOSAL_ID} yes --from validator --yes -t --home ${PROVENANCE_DEV_DIR}/build/run/provenanced --fees 10000000000000nhash --chain-id testing --keyring-backend test -o json | jq

# nhash-per-usd-mil <title> <description> <nhash-per-usd-mil> <deposit>