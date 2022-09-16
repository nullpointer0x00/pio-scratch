#!/bin/bash
PROVENANCE_DEV_DIR=~/code/provenance
DEPOSIT=1vspn
UPGRADE_HEIGHT=50
PROPOSAL_ID=1

echo "ADDING UPGRADE PROPOSAL"
${PROVENANCE_DEV_DIR}/build/provenanced tx msgfees conversion-fee-denom \
"Change conversion fee denom to ibc thing" \
"Changing conversion fee denom to ibc thing description" \
"ibc/319937B2FDA7A07031DBE22EA76C34CAC9DCFBD9AA1A922FA2B87421107B545D" \
${DEPOSIT} \
    --from validator \
    --yes -t --home ${PROVENANCE_DEV_DIR}/build/run/provenanced \
    --fees 1vspn --chain-id testing-custom-vspn-2 --keyring-backend test -o json | jq
echo "VOTING ON PROPOSAL"
${PROVENANCE_DEV_DIR}/build/provenanced tx gov vote ${PROPOSAL_ID} yes --from validator --yes -t --home ${PROVENANCE_DEV_DIR}/build/run/provenanced --fees 1vspn --chain-id testing-custom-vspn-2 --keyring-backend test -o json | jq
