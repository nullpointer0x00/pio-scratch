#!/bin/bash

#Provenance Configuration
PROVENANCE_DEV_DIR=~/code/provenance
CHAIN_ID=testing
FROM=validator
PROPOSAL_FEE=1000000000vspn
DEPOSIT=10000000000vspn

# Fee Configuration
MSG_TYPE=/cosmos.bank.v1beta1.MsgSend
MSG_FEE=5ibc/319937B2FDA7A07031DBE22EA76C34CAC9DCFBD9AA1A922FA2B87421107B545D

PROVENANCE_BIN="$PROVENANCE_DEV_DIR/build/provenanced"
PROVENANCE_HOME="$PROVENANCE_DEV_DIR/build/run/provenanced"
PROPOSAL_ID=$($PROVENANCE_BIN -t --home $PROVENANCE_HOME q gov proposals | grep "id:" | wc -l | sed 's/ //g')
PROPOSAL_ID=$(echo $(( $PROPOSAL_ID + 1 )))

echo "ADDING PROPOSAL RIGHT NOW"
"$PROVENANCE_BIN" tx msgfees proposal add "adding" "adding msgsend fee" "$DEPOSIT" --msg-type "${MSG_TYPE}" --additional-fee $MSG_FEE  --from $FROM --yes -t --home ${PROVENANCE_DEV_DIR}/build/run/provenanced --fees "$PROPOSAL_FEE" --chain-id $CHAIN_ID --keyring-backend test -o json | jq
echo "VOTING ON PROPOSAL"
"$PROVENANCE_BIN" tx gov vote "$PROPOSAL_ID" yes --from $FROM --yes -t --home $PROVENANCE_HOME --fees "$PROPOSAL_FEE" --chain-id $CHAIN_ID --keyring-backend test -o json | jq
echo "AFTER VOTING"