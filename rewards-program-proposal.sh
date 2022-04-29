#!/bin/bash
PROVENANCE_DEV_DIR=~/code/provenance
DESCRIPTION="reward-program-description"
TITLE="reward-program-title"
DEPOSIT=100000000000nhash
VALIDATOR_ID=$(${PROVENANCE_DEV_DIR}/build/provenanced keys show -a validator --home ${PROVENANCE_DEV_DIR}/build/run/provenanced -t)
BUYER=$(${PROVENANCE_DEV_DIR}/build/provenanced keys show -a buyer --home ${PROVENANCE_DEV_DIR}/build/run/provenanced -t)

PROPOSAL_ID=1

echo "ADDING REWARDS PROGRAM PROPOSAL"
${PROVENANCE_DEV_DIR}/build/provenanced tx reward proposal add "${TITLE}" "${DESCRIPTION}" ${DEPOSIT} \
    --coin 100000000000000nhash \
    --reward-program-id 1 \
    --dist-address ${BUYER} \
    --epoch-id minute \
    --epoch-offset 1 \
    --num-epochs 5 \
    --minimum 2 \
    --maximum 10 \
    --eligibility-criteria "{\"name\":\"name\",\"action\":{\"@type\":\"/provenance.reward.v1.ActionDelegate\"}}" \
    --from buyer \
    --yes -t --home ${PROVENANCE_DEV_DIR}/build/run/provenanced \
    --gas auto --gas-prices 1905nhash --gas-adjustment 2 --chain-id testing --keyring-backend test -o json | jq
echo "VOTING ON PROPOSAL"
${PROVENANCE_DEV_DIR}/build/provenanced tx gov vote ${PROPOSAL_ID} yes --from validator --yes -t --home ${PROVENANCE_DEV_DIR}/build/run/provenanced --fees 10000000000000nhash --chain-id testing --keyring-backend test -o json | jq
