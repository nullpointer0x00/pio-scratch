#!/bin/bash

# Provenance Configuration
PROVENANCE_DEV_DIR=~/code/provenance
DEPOSIT=10000000vspn
UPGRADE_HEIGHT=50
FROM=validator
CHAIN_ID=testing
DENOM_TO_USE=ibc/319937B2FDA7A07031DBE22EA76C34CAC9DCFBD9AA1A922FA2B87421107B545D
LOCAL_FEE=1vspn

PROVENANCE_BIN="$PROVENANCE_DEV_DIR/build/provenanced"
PROVENANCE_HOME="$PROVENANCE_DEV_DIR/build/run/provenanced"
PROPOSAL_ID=$($PROVENANCE_BIN -t --home $PROVENANCE_HOME q gov proposals | grep "id:" | wc -l | sed 's/ //g')
PROPOSAL_ID=$(echo $(( $PROPOSAL_ID + 1 )))

echo "ADDING UPGRADE PROPOSAL"
"$PROVENANCE_BIN" tx msgfees conversion-fee-denom "Change conversion fee denom to ibc thing" "Changing conversion fee denom to ibc thing description" "$DENOM_TO_USE" \
${DEPOSIT} \
    --from $FROM \
    --yes -t --home "$PROVENANCE_HOME" \
    --fees "$LOCAL_FEE" --chain-id "$CHAIN_ID" --keyring-backend test -o json | jq
echo "VOTING ON PROPOSAL"
"$PROVENANCE_BIN" tx gov vote ${PROPOSAL_ID} yes --from $FROM --yes -t --home "$PROVENANCE_HOME" --fees "$LOCAL_FEE" --chain-id "$CHAIN_ID" --keyring-backend test -o json | jq
