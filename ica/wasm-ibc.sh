#!/bin/bash

export PROVENANCE_DIR="$HOME/code/provenance"
export BIN="$PROVENANCE_DIR/build/provenanced"
export RUN_HOME="$PROVENANCE_DIR/build/run/provenanced"
export RUN2_HOME="$PROVENANCE_DIR/build/run2/provenanced"
export RUN2_CONFIG_PATH="$HOME/code"
export GAS_FLAGS="--gas auto --gas-prices 1905nhash --gas-adjustment 1.5"
export CHAIN1="$BIN -t --home $RUN_HOME"
export CHAIN2="$BIN -t --home $RUN2_HOME"
export VALIDATOR1=$($CHAIN1 keys show validator -a)
export VALIDATOR2=$($CHAIN2 keys show validator -a)
WASM_IBC_PROJECT="ibc-tutorial-wasm"
PATH_TUTORIAL="$HOME/code/$WASM_IBC_PROJECT"

echo ${VALIDATOR1}
echo ${VALIDATOR2}
IBC_REFLECT_WASM="$PATH_TUTORIAL/demos/reflect/ibc-reflect/artifacts/ibc_reflect-aarch64.wasm"
REFLECT_WASM="$PATH_TUTORIAL/demos/reflect/reflect/artifacts/reflect-aarch64.wasm"

IBC_REFLECT_SEND_WASM="$PATH_TUTORIAL/demos/reflect/ibc-reflect-send/artifacts/ibc_reflect_send-aarch64.wasm"

# read -p "Storing ibc reflect on chain 2..."
# ${CHAIN2} tx wasm store ${IBC_REFLECT_WASM} --from $VALIDATOR2 ${GAS_FLAGS} -y -o json | jq
# read -p "Storing reflect on chain 2..."
# ${CHAIN2} tx wasm store ${REFLECT_WASM} --from $VALIDATOR2 ${GAS_FLAGS} -y -o json | jq

# read -p "Storing ibc reflect senb on chain 1..."
# ${CHAIN1} tx wasm store ${IBC_REFLECT_SEND_WASM} --from $VALIDATOR1 ${GAS_FLAGS} -y -o json | jq

# # ${CHAIN1} q wasm list-code -o json | jq
# # ${CHAIN2} q wasm list-code -o json | jq 
# # tp14hj2tavq8fpesdwxxcu44rty3hh90vhujrvcmstl4zr3txmfvw9s96lrg8
# # tp14hj2tavq8fpesdwxxcu44rty3hh90vhujrvcmstl4zr3txmfvw9s96lrg8
# # export CODE_ID=2
# # export JSON_1=(printf "{\"reflect_code_id\": %s}" "CODE_ID")
# read -p "Instantiate ibc-reflect on chain 2..."
# echo "INSTANTIATE ibc-reflect chain2"
# ${CHAIN2} tx wasm instantiate 1 "{\"reflect_code_id\": 2}" --label "ibc-reflect" --admin $VALIDATOR2 --from $VALIDATOR2 ${GAS_FLAGS} -y -o json | jq

# read -p "Instantiate ibc-reflect-send on chain 1..."
# echo "INSTANTIATE ibc-reflect-send chain1"
# ${CHAIN1} tx wasm instantiate 1 "{}" --label "ibc-reflect-send"  --admin $VALIDATOR1 --from $VALIDATOR1 ${GAS_FLAGS} -y -o json | jq

# read -p "Setup Channel"

# rly tx channel local_local2 --dst-port "wasm.tp14hj2tavq8fpesdwxxcu44rty3hh90vhujrvcmstl4zr3txmfvw9s96lrg8" --src-port "wasm.tp14hj2tavq8fpesdwxxcu44rty3hh90vhujrvcmstl4zr3txmfvw9s96lrg8" --order ordered --version "ibc-reflect-v1"

# # read -p "Send Funds"
# # ${CHAIN1} tx wasm execute tp14hj2tavq8fpesdwxxcu44rty3hh90vhujrvcmstl4zr3txmfvw9s96lrg8 '{"send_funds":{"reflect_channel_id": "channel-1", "transfer_channel_id": "channel-0"}}' --amount 100nhash --from $VALIDATOR1 --fees 382000000nhash -y -o json
# # ${CHAIN1} q wasm contract-state smart tp14hj2tavq8fpesdwxxcu44rty3hh90vhujrvcmstl4zr3txmfvw9s96lrg8 '{"admin":{}}'
# # ${CHAIN2} q wasm list-contract-by-code 2 -o json | jq

# # tp14hj2tavq8fpesdwxxcu44rty3hh90vhujrvcmstl4zr3txmfvw9s96lrg8
# read -p "Send Hash"
# ${CHAIN2} tx bank send $VALIDATOR2 tp1nc5tatafv6eyq7llkr2gv50ff9e22mnf70qgjlv737ktmt4eswrqf06p2p 1000000000000nhash --fees 10000000000nhash -y -o json | jq
# read -p "Check Balance"
# ${CHAIN2} q bank balances tp1nc5tatafv6eyq7llkr2gv50ff9e22mnf70qgjlv737ktmt4eswrqf06p2p -o json | jq

# read -p "Send Hash"
# ${CHAIN1} tx bank send $VALIDATOR1 tp14hj2tavq8fpesdwxxcu44rty3hh90vhujrvcmstl4zr3txmfvw9s96lrg8 1000000000000nhash --gas auto --gas-prices 1905nhash --gas-adjustment 1.5 -y -o json | jq
# read -p "Check Balance"
# ${CHAIN1} q bank balances tp14hj2tavq8fpesdwxxcu44rty3hh90vhujrvcmstl4zr3txmfvw9s96lrg8 -o json | jq

read -p "Send msgs"
${CHAIN1} tx wasm execute tp14hj2tavq8fpesdwxxcu44rty3hh90vhujrvcmstl4zr3txmfvw9s96lrg8 '{"send_msgs":{"channel_id": "channel-1", "msgs":[{"bank":{"send":{"from_address":"tp13g9hxkljph90nt2waxtw3a40fkkz0dta3sgztv", "to_address": "tp13g9hxkljph90nt2waxtw3a40fkkz0dta3sgztv","amount":[{"denom": "nhash","amount": "420"}]}}}]}}' --amount 100nhash --from $VALIDATOR1 --fees 382000000nhash -y -o json | jq

read -p "Check Balances"
${CHAIN2} q bank balances tp13g9hxkljph90nt2waxtw3a40fkkz0dta3sgztv -o json | jq
${CHAIN2} q bank balances tp14hj2tavq8fpesdwxxcu44rty3hh90vhujrvcmstl4zr3txmfvw9s96lrg8 -o json | jq