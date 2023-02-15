#!/bin/bash

PROVENANCE_DIR="$HOME/code/provenance"
BIN="$PROVENANCE_DIR/build/provenanced"
RUN_HOME="$PROVENANCE_DIR/build/run/provenanced"
RUN2_HOME="$PROVENANCE_DIR/build/run2/provenanced"
RUN2_CONFIG_PATH="$HOME/code"
RELAYER1=$(rly keys show local)
RELAYER2=$(rly keys show local2)
GAS_FLAGS="--gas auto --gas-prices 1905nhash --gas-adjustment 1.5"

CHAIN1="$BIN -t --home $RUN_HOME"
CHAIN2="$BIN -t --home $RUN2_HOME"

cd $PROVENANCE_DIR

# Setup environment
make clean
make build
make run-config CHAIN_ID=testing
make run2-config
cp ~/Desktop/run2Config/* ~/code/provenance/build/run2/provenanced/config/.

# Start the two chains
# make run &> chain1.log &
# make run2 &> chain2.log &

# Wait for the two chains to initialize
read -p "Start both chains then hit enter..."


# Get validator addresses
VALIDATOR1=$($CHAIN1 keys show validator -a)
VALIDATOR2=$($CHAIN2 keys show validator -a)

# Fund relayers
$CHAIN1 tx bank send validator $RELAYER1 1000000000000nhash --fees 500000000nhash -y -o json | jq
$CHAIN2 tx bank send validator $RELAYER2 1000000000000nhash --fees 10500000000nhash  -y -o json | jq 

read -p "Edit relayer config then hit enter... vi ~/.relayer/config/config.yaml"

# Setup Connection
rly tx link local_local2

# exit

# # Get the connection id
# CONNECTION=

# Wait for the relayer
read -p "Start relayer then hit enter"
# Start the relayer
make relayer-start RELAY_PATH=local_local2

# Register ICA
# $CHAIN1 tx intertx register --from $VALIDATOR1 --connection-id $CONNECTION --chain-id testing --fees 382000000nhash