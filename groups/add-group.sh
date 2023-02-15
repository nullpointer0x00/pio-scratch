#!/bin/bash

export PROVENANCE_DIR="$HOME/code/provenance"
export BIN="$PROVENANCE_DIR/build/provenanced"
export RUN_HOME="$PROVENANCE_DIR/build/run/provenanced"
export MEMBERS_FILE="$HOME/code/pio-scratch/groups/members.json"
export POLICY_FILE="$HOME/code/pio-scratch/groups/policy.json"
export GAS_FLAGS="--gas auto --gas-prices 1905nhash --gas-adjustment 1.5"
export CHAIN="$BIN -t --home $RUN_HOME"
export VALIDATOR=$($CHAIN keys show validator -a)
# tp13g9hxkljph90nt2waxtw3a40fkkz0dta3sgztv
export MNEMONIC1="./mnemonics/seller.txt"
export ACCT1_NAME="acct1"
export ACCT1_KEY=$($CHAIN keys show $ACCT1_NAME -a --keyring-backend test)

#tp13hp0ts7xkqx4qj3yesthzs7an4hrtrm8ygxxcn
export MNEMONIC2="./mnemonics/buyer.txt"
export ACCT2_NAME="acct2"
export ACCT2_KEY=$($CHAIN keys show $ACCT2_NAME -a)

export MNEMONIC3="./mnemonics/consumer.txt"
export ACCT3_NAME="acct3"
export ACCT3_KEY=$($CHAIN keys show $ACCT3_NAME -a)

$CHAIN tx bank send validator $ACCT1_KEY 1000000000000nhash --fees 500000000nhash -y -o json | jq
$CHAIN tx bank send validator $ACCT2_KEY 1000000000000nhash --fees 500000000nhash -y -o json | jq
$CHAIN tx bank send validator $ACCT3_KEY 1000000000000nhash --fees 500000000nhash -y -o json | jq

$CHAIN tx group create-group-with-policy $VALIDATOR "group-metadata" "group-policy-metadata" $MEMBERS_FILE $POLICY_FILE --from $VALIDATOR $GAS_FLAGS --keyring-backend test -y -o json | jq

echo "Query group admin"
echo "-----------------------------------------------"
$CHAIN q group groups-by-admin $VALIDATOR -o json | jq
echo ""
echo ""
echo ""
echo ""
echo "Query group members"
echo "-----------------------------------------------"
$CHAIN q group group-members 1 -o json | jq
echo ""
echo ""
echo ""
echo "Query group policies by group"
echo "-----------------------------------------------"
$CHAIN q group group-policies-by-group 1 -o json | jq
echo ""
echo ""
echo ""
echo "Query group policies by admin"
echo "-----------------------------------------------"
$CHAIN q group group-policies-by-admin $VALIDATOR -o json | jq