#!/bin/bash
PROVENANCE_DEV_DIR=~/code/provenance
MSG_TYPE=/cosmos.bank.v1beta1.MsgSend
PROPOSAL_ID=1

echo "ADDING PROPOSAL RIGHT NOW"
${PROVENANCE_DEV_DIR}/build/provenanced tx msgfees proposal add "adding" "adding msgsend fee"  1vspn --msg-type "${MSG_TYPE}" --additional-fee 1ibc/319937B2FDA7A07031DBE22EA76C34CAC9DCFBD9AA1A922FA2B87421107B545D  --from validator --yes -t --home ${PROVENANCE_DEV_DIR}/build/run/provenanced --fees 0vspn --chain-id testing-custom-vspn-2 --keyring-backend test -o json | jq
echo "VOTING ON PROPOSAL"
${PROVENANCE_DEV_DIR}/build/provenanced tx gov vote ${PROPOSAL_ID} yes --from validator --yes -t --home ${PROVENANCE_DEV_DIR}/build/run/provenanced --fees 1vspn --chain-id testing-custom-vspn-2 --keyring-backend test -o json | jq
echo "AFTER VOTING"