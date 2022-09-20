#!/bin/bash

# Provenance Configuration
SCRIPTS_DIR=~/code/pio-scratch
PROVENANCE_SCRIPT=$SCRIPTS_DIR/simple/provenance.sh
source $PROVENANCE_SCRIPT

# Args
SENDER=$1
RECEIVER=$2
AMOUNT=$3

transaction bank send $SENDER $RECEIVER $AMOUNT