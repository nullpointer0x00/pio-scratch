#!/bin/bash
PROVENANCE_DEV_DIR=~/code/provenance

echo "ADDING PROPOSAL RIGHT NOW"
${PROVENANCE_DEV_DIR}/build/provenanced tx msgfees proposal add "adding" "adding msgsend fee"  10000000000nhash --msg-type "/cosmos.bank.v1beta1.MsgSend" --amount 1nhash --additional-fee 1999999999nhash  --from validator --yes -t --home ${PROVENANCE_DEV_DIR}/build/run/provenanced --fees 1000000000nhash --chain-id testing --keyring-backend test -o json | jq
echo "VOTING ON PROPOSAL"
${PROVENANCE_DEV_DIR}/build/provenanced tx gov vote 1 yes --from validator --yes -t --home ${PROVENANCE_DEV_DIR}/build/run/provenanced --fees 1000000000nhash --chain-id testing --keyring-backend test -o json | jq
echo "AFTER VOTING"