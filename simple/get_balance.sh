#!/bin/bash

# Provenance Configuration
SCRIPTS_DIR=~/code/pio-scratch
PROVENANCE_SCRIPT=$SCRIPTS_DIR/simple/provenance.sh
source $PROVENANCE_SCRIPT

# Args
ADDRESS=$1

query bank balances $ADDRESS