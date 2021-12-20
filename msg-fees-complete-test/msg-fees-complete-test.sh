#!/bin/bash

PROVENANCE_DEV_DIR=~/code/provenance
PROVENANCE_DEV_BUILD=build/provenanced
PIO_ENV_FLAGS="-t --home ${PROVENANCE_DEV_DIR}/build/run/provenanced"
PIO_CMD="${PROVENANCE_DEV_DIR}/${PROVENANCE_DEV_BUILD} ${PIO_ENV_FLAGS}"

PIO_ENV_FLAGS="-t --home ${PROVENANCE_DEV_DIR}/build/run/provenanced"
GEN_TMP_DIR=test-tmp/
COMMON_TX_FLAGS="--chain-id testing --keyring-backend test --yes -o json"
GAS_FLAGS="--gas auto --gas-prices 1905nhash"
GAS_ADJUSTMENT="--gas-adjustment 2"

MSG_TYPE=/cosmos.bank.v1beta1.MsgSend
PROPOSAL_ID=1
NHASH_ADDITIONAL_FEE=300000000000

VALIDATOR_ID=$(${PIO_CMD} keys show -a validator) 
BUYER=$(${PIO_CMD} keys show -a buyer) 
SELLER=$(${PIO_CMD} keys show -a seller) 


# echo "Funding additional accounts with nhash"
# ${PROVENANCE_DEV_DIR}/build/provenanced -t --home ${PROVENANCE_DEV_DIR}/build/run/provenanced tx bank send ${VALIDATOR_ID} ${BUYER} 10000000000000nhash  \
#     --from validator \
#     ${COMMON_TX_FLAGS} | jq

# ${PROVENANCE_DEV_DIR}/build/provenanced -t --home ${PROVENANCE_DEV_DIR}/build/run/provenanced tx bank send ${VALIDATOR_ID} ${SELLER} 10000000000000nhash  \
#     --from validator \
#     ${COMMON_TX_FLAGS} | jq

VALIDATOR_NHASH_BALANCE=$(${PIO_CMD} q bank balances ${VALIDATOR_ID} -o json | jq '.balances[]| select(.denom =="nhash") | .amount | tonumber')

# echo "Validator nhash ${VALIDATOR_NHASH_BALANCE}"
# echo "Generating send...to be used for simulation"
# mkdir ${GEN_TMP_DIR}
# ${PIO_CMD} tx bank send ${VALIDATOR_ID} ${SELLER} 100000000000nhash  \
#     --from validator --generate-only | jq > ${GEN_TMP_DIR}/tmp.generated.send.json
# echo "Signing send....to be used for simulation"
# ${PIO_CMD} tx sign ${GEN_TMP_DIR}/tmp.generated.send.json --from ${VALIDATOR_ID} ${COMMON_TX_FLAGS} | jq> ${GEN_TMP_DIR}/tmp.generated.send.json.signed
# echo "Run Simulate through custom pio simulate to capture any additional fees using gas adjustment ${GAS_ADJUSTMENT}"
# ${PIO_CMD} tx simulate ${GEN_TMP_DIR}/tmp.generated.send.json.signed ${COMMON_TX_FLAGS} --from ${VALIDATOR_ID} ${GAS_ADJUSTMENT} | jq > ${GEN_TMP_DIR}/simulate.response.json
# TOTAL_FEE_NHASH=$(cat ${GEN_TMP_DIR}/simulate.response.json | jq '.total_fees[] | select(.denom=="nhash") | .amount | tonumber')
# echo "Estimated total fee $TOTAL_FEE_NHASH"
# ESTIMTATED_GAS=$(cat ${GEN_TMP_DIR}/simulate.response.json  | jq '.estimated_gas | tonumber')
# echo "Estimated total estimated gas $ESTIMTATED_GAS"
# echo "Running bank send with new estimated gas and fees..."
# ${PIO_CMD} tx bank send ${VALIDATOR_ID} ${SELLER} 100000000000nhash  \
#     --from validator ${COMMON_TX_FLAGS} --gas ${ESTIMTATED_GAS} --fees ${TOTAL_FEE_NHASH}nhash | jq

# ${PIO_CMD} q bank balances ${VALIDATOR_ID} -o json | jq '.balances[]| select(.denom =="nhash") | .amount | tonumber'

# # Do some math here...

echo "Adding proposal for additional fees on msg sends of nhash"
${PIO_CMD} tx msgfees proposal add "adding" "adding msgsend fee"  10000000000nhash --msg-type "${MSG_TYPE}" --additional-fee ${NHASH_ADDITIONAL_FEE}nhash  --from validator  --fees 1000000000nhash ${COMMON_TX_FLAGS} | jq
echo "Voting on additional fees for msg sends"
${PIO_CMD} tx gov vote ${PROPOSAL_ID} yes --from validator --fees 1000000000nhash ${COMMON_TX_FLAGS} | jq
echo "Sleeping for voting period time to elapse"
sleep 10
echo "List new msg based fees...should contain new msg type fee"
${PIO_CMD} q msgfees list -o json | jq 

${PIO_CMD} tx bank send ${VALIDATOR_ID} ${SELLER} 100000000000nhash  \
    --from validator --generate-only | jq > ${GEN_TMP_DIR}/tmp.generated.send.json
echo "Signing send....to be used for simulation"
${PIO_CMD} tx sign ${GEN_TMP_DIR}/tmp.generated.send.json --from ${VALIDATOR_ID} ${COMMON_TX_FLAGS} | jq> ${GEN_TMP_DIR}/tmp.generated.send.json.signed
echo "Run Simulate through custom pio simulate to capture any additional fees using gas adjustment ${GAS_ADJUSTMENT}"
${PIO_CMD} tx simulate ${GEN_TMP_DIR}/tmp.generated.send.json.signed ${COMMON_TX_FLAGS} --from ${VALIDATOR_ID} ${GAS_ADJUSTMENT} | jq > ${GEN_TMP_DIR}/simulate.response.json
TOTAL_FEE_NHASH=$(cat ${GEN_TMP_DIR}/simulate.response.json | jq '.total_fees[] | select(.denom=="nhash") | .amount | tonumber')
echo "Estimated total fee $TOTAL_FEE_NHASH"
ESTIMTATED_GAS=$(cat ${GEN_TMP_DIR}/simulate.response.json  | jq '.estimated_gas | tonumber')
echo "Estimated total estimated gas $ESTIMTATED_GAS"
echo "Running bank send with new estimated gas and fees..."
${PIO_CMD} tx bank send ${VALIDATOR_ID} ${SELLER} 100000000000nhash  \
    --from validator ${COMMON_TX_FLAGS} --gas ${ESTIMTATED_GAS} --fees ${TOTAL_FEE_NHASH}nhash | jq

${PIO_CMD} q bank balances ${VALIDATOR_ID} -o json | jq '.balances[]| select(.denom =="nhash") | .amount | tonumber'

FEE_WITHOUT_ADDITIONAL=$(expr ${TOTAL_FEE_NHASH} - ${NHASH_ADDITIONAL_FEE})
echo "Fee without additional fee ${FEE_WITHOUT_ADDITIONAL}...try and send but should fail."
${PIO_CMD} tx bank send ${VALIDATOR_ID} ${SELLER} 100000000000nhash  \
    --from validator ${COMMON_TX_FLAGS} --gas ${ESTIMTATED_GAS} --fees ${FEE_WITHOUT_ADDITIONAL}nhash | jq

# rm -rf ${GEN_TMP_DIR}