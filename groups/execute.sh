#!/bin/bash

export PROVENANCE_DIR="$HOME/code/provenance"
export BIN="$PROVENANCE_DIR/build/provenanced"
export RUN_HOME="$PROVENANCE_DIR/build/run/provenanced"
export PROPOSAL_FILE="$HOME/code/pio-scratch/groups/proposal.json"
export GAS_FLAGS="--gas auto --gas-prices 1905nhash --gas-adjustment 1.5"
export CHAIN="$BIN -t --home $RUN_HOME --keyring-backend test"
export VALIDATOR=$($CHAIN keys show validator -a)
# tp13g9hxkljph90nt2waxtw3a40fkkz0dta3sgztv
export ACCT1_NAME="acct1"
export ACCT1_KEY=$($CHAIN keys show $ACCT1_NAME -a)

#tp13hp0ts7xkqx4qj3yesthzs7an4hrtrm8ygxxcn
export ACCT2_NAME="acct2"
export ACCT2_KEY=$($CHAIN keys show $ACCT2_NAME -a)

export ACCT3_NAME="acct3"
export ACCT3_KEY=$($CHAIN keys show $ACCT3_NAME -a)

export VALIDATOR=$($CHAIN keys show validator -a)

$CHAIN tx group exec 1 --from $VALIDATOR $GAS_FLAGS -y -o json | jq