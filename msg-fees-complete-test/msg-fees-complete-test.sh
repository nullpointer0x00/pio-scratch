#!/bin/bash

PROVENANCE_DEV_DIR=~/code/provenance
PROVENANCE_DEV_BUILD=build/provenanced
PIO_ENV_FLAGS="-t --home ${PROVENANCE_DEV_DIR}/build/run/provenanced"
PIO_CMD="${PROVENANCE_DEV_DIR}/${PROVENANCE_DEV_BUILD} ${PIO_ENV_FLAGS}"

PIO_ENV_FLAGS="-t --home ${PROVENANCE_DEV_DIR}/build/run/provenanced"
GEN_TMP_DIR=test-tmp
COMMON_TX_FLAGS="--chain-id testing --keyring-backend test --yes -o json"
GAS_FLAGS="--gas auto --gas-prices 1905nhash"
GAS_ADJUSTMENT="--gas-adjustment 1.5"

MSG_TYPE=/cosmos.bank.v1beta1.MsgSend
NHASH_ADDITIONAL_FEE=1000000000
NHASH_SEND_AMOUNT=100000000000
MIN_GAS_PRICE=1905

VALIDATOR_ID=$(${PIO_CMD} keys show -a validator) 
BUYER=$(${PIO_CMD} keys show -a buyer) 
BUYER_INIT_BALANCE=10000000000000
SELLER=$(${PIO_CMD} keys show -a seller) 

BUYER_NHASH_BALANCE=$(${PIO_CMD} q bank balances ${BUYER} -o json | jq '.balances[]| select(.denom =="nhash") | .amount | tonumber')
if [ -z $BUYER_NHASH_BALANCE ] 
then 
    BUYER_NHASH_BALANCE=0
fi 

if [ $BUYER_NHASH_BALANCE -lt $BUYER_INIT_BALANCE ] 
then 
    SEND_AMOUNT=$(echo "${BUYER_INIT_BALANCE} - ${BUYER_NHASH_BALANCE}" | bc)
    echo "Funding buyer account with ${SEND_AMOUNT} nhash"

    ${PIO_CMD} tx bank send ${VALIDATOR_ID} ${BUYER} ${SEND_AMOUNT}nhash  \
        --from validator \
        ${COMMON_TX_FLAGS} --fees 10000000000nhash | jq > ${GEN_TMP_DIR}/fund.buyer.response.json
    CODE=$(cat ${GEN_TMP_DIR}/fund.buyer.response.json | jq '.code | tonumber')
    if [ $CODE -ne 0 ]
    then
        echo "funding buyer tx failed with code: ${CODE}"
        cat ${GEN_TMP_DIR}/fund.buyer.response.json
        exit 1
    fi
fi


BUYER_NHASH_BALANCE=$(${PIO_CMD} q bank balances ${BUYER} -o json | jq '.balances[]| select(.denom =="nhash") | .amount | tonumber')
echo "Generating send...to be used for simulate tx"
mkdir ${GEN_TMP_DIR}
${PIO_CMD} tx bank send ${BUYER} ${SELLER} 100000000000nhash  \
    --from ${BUYER} --generate-only | jq > ${GEN_TMP_DIR}/tmp.generated.send.json
echo "Signing send....to be used for simulate tx"
${PIO_CMD} tx sign ${GEN_TMP_DIR}/tmp.generated.send.json --from ${BUYER} ${COMMON_TX_FLAGS} | jq> ${GEN_TMP_DIR}/tmp.generated.send.json.signed
echo "Run Simulate through custom pio simulate to capture any additional fees using gas adjustment ${GAS_ADJUSTMENT}"
${PIO_CMD} tx simulate ${GEN_TMP_DIR}/tmp.generated.send.json.signed ${COMMON_TX_FLAGS} --from ${BUYER} ${GAS_ADJUSTMENT} | jq > ${GEN_TMP_DIR}/simulate.response.json

TOTAL_FEES=$(cat test-tmp/simulate.response.json | jq '.total_fees[] | .amount+.denom ' | tr -d '"' | paste -s -d, -)
TOTAL_FEE_NHASH=$(cat test-tmp/simulate.response.json | jq '.total_fees[]| select(.denom =="nhash") | .amount | tonumber')
echo "Estimated total fee $TOTAL_FEES"
ESTIMTATED_GAS=$(cat ${GEN_TMP_DIR}/simulate.response.json  | jq '.estimated_gas | tonumber')
echo "Estimated gas $ESTIMTATED_GAS"
echo "Running bank send with new estimated gas and fees..."
${PIO_CMD} tx bank send ${BUYER} ${SELLER} ${NHASH_SEND_AMOUNT}nhash  \
    --from ${BUYER} ${COMMON_TX_FLAGS} --gas ${ESTIMTATED_GAS} --fees ${TOTAL_FEES}| jq > ${GEN_TMP_DIR}/send.response.json
CODE=$(cat ${GEN_TMP_DIR}/send.response.json | jq '.code | tonumber')
if [ $CODE -ne 0 ]
then
    echo "bank send tx failed failed with code: ${CODE}"
    cat ${GEN_TMP_DIR}/send.response.json 
    exit 1
fi

EXPECTED_NHASH_BALANCE=$(echo "${BUYER_NHASH_BALANCE} - ${NHASH_SEND_AMOUNT} - ${TOTAL_FEE_NHASH}" | bc)
RESULT_NHASH_BALANCE=$(${PIO_CMD} q bank balances ${BUYER} -o json | jq '.balances[]| select(.denom =="nhash") | .amount | tonumber')
echo "Buyer balance, expected: ${EXPECTED_NHASH_BALANCE}  actual: ${RESULT_NHASH_BALANCE} original ${BUYER_NHASH_BALANCE}"
if [ $EXPECTED_NHASH_BALANCE -ne $RESULT_NHASH_BALANCE ]
then
    echo "${EXPECTED_NHASH_BALANCE} -neq ${RESULT_NHASH_BALANCE}"
    exit 1
fi

########
#   1.) With gov proposal add additional fee in nhash for msg type: /cosmos.bank.v1beta1.MsgSend
#   2.) Generate and sign a single send tx
#   3.) Simulate the tx and get total gas estimated and fees required
#   4.) Do send with the simulated gas and fee values
#########
echo "Adding proposal for additional fees on msg sends of nhash"
${PIO_CMD} tx msgfees proposal add "adding" "adding msgsend fee"  10000000000nhash --msg-type "${MSG_TYPE}" --additional-fee ${NHASH_ADDITIONAL_FEE}nhash  --from validator  --fees 1000000000nhash ${COMMON_TX_FLAGS} | jq > ${GEN_TMP_DIR}/add-proposal.json
PROPOSAL_ID=$(cat ${GEN_TMP_DIR}/add-proposal.json | jq ' .logs[0].events[] | select(.type=="submit_proposal") | .attributes[] | select(.key=="proposal_id") | .value | tonumber')
echo "Voting proposal id ${PROPOSAL_ID} for additional fees for msg sends"
${PIO_CMD} tx gov vote ${PROPOSAL_ID} yes --from validator --fees 1000000000nhash ${COMMON_TX_FLAGS} | jq > ${GEN_TMP_DIR}/add-proposal-vote.json
echo "Sleeping for voting period time to elapse"
sleep 6 
${PIO_CMD} q msgfees list -o json | jq > ${GEN_TMP_DIR}/list.msgfees.json
if [ $(cat ${GEN_TMP_DIR}/list.msgfees.json | jq '.msg_fees | length') -ne 1 ] || [ $(cat ${GEN_TMP_DIR}/list.msgfees.json | jq -r '.msg_fees[0].msg_type_url') != $MSG_TYPE ]
then
    echo "Failed to add msg fee with gov proposal."
    echo "$(cat ${GEN_TMP_DIR}/list.msgfees.json | jq '.msg_fees | length') -ne 2"
    echo "$(cat ${GEN_TMP_DIR}/list.msgfees.json | jq '.msg_fees[0].msg_type_url') -ne $MSG_TYPE"
    exit 1
fi 

${PIO_CMD} tx bank send ${BUYER} ${SELLER} 100000000000nhash  \
    --from ${BUYER} --generate-only | jq > ${GEN_TMP_DIR}/tmp.generated.send.json
echo "Signing send....to be used for simulate tx"
${PIO_CMD} tx sign ${GEN_TMP_DIR}/tmp.generated.send.json --from ${BUYER} ${COMMON_TX_FLAGS} | jq > ${GEN_TMP_DIR}/tmp.generated.send.json.signed
echo "Run Simulate through custom pio simulate to capture any additional fees using gas adjustment ${GAS_ADJUSTMENT}"
${PIO_CMD} tx simulate ${GEN_TMP_DIR}/tmp.generated.send.json.signed ${COMMON_TX_FLAGS} --from ${BUYER} ${GAS_ADJUSTMENT} | jq > ${GEN_TMP_DIR}/simulate.response.json
TOTAL_FEES=$(cat ${GEN_TMP_DIR}/simulate.response.json | jq '.total_fees[] | .amount+.denom ' | tr -d '"' | paste -s -d, -)
echo "Estimated total fee $TOTAL_FEES"
TOTAL_FEE_NHASH=$(cat ${GEN_TMP_DIR}/simulate.response.json | jq '.balances[]| select(.denom =="nhash") | .amount | tonumber')
ESTIMTATED_GAS=$(cat ${GEN_TMP_DIR}/simulate.response.json  | jq '.estimated_gas | tonumber')
FEE_WITHOUT_ADDITIONAL=$(expr ${TOTAL_FEE_NHASH} - ${NHASH_ADDITIONAL_FEE})
BASE_FEE=$(expr ${ESTIMATED_GAS} * ${MIN_GAS_PRICE})
echo "Estimated gas $ESTIMTATED_GAS"
if [ ${BASE_FEE} -ne ${FEE_WITHOUT_ADDITIONAL}]
then
    echo "Incorrect base fee estimation. ${BASE_FEE} -ne ${FEE_WITHOUT_ADDITIONAL}"
    exit 1
fi
exit 0
echo "Running bank send with new estimated gas and fees..."
${PIO_CMD} tx bank send ${BUYER} ${SELLER} 100000000000nhash  \
    --from ${BUYER} ${COMMON_TX_FLAGS} --gas ${ESTIMTATED_GAS} --fees ${TOTAL_FEES} | jq

${PIO_CMD} q bank balances ${BUYER} -o json | jq '.balances[]| select(.denom =="nhash") | .amount | tonumber'

echo "Fee without additional fee ${FEE_WITHOUT_ADDITIONAL}...try and send but should fail."
${PIO_CMD} tx bank send ${VALIDATOR_ID} ${SELLER} 100000000000nhash  \
    --from validator ${COMMON_TX_FLAGS} --gas ${ESTIMTATED_GAS} --fees ${FEE_WITHOUT_ADDITIONAL}nhash | jq

echo "Creating marker usd"
${PIO_CMD} tx marker new 1000000usd.local --type COIN --from validator \
    ${COMMON_TX_FLAGS} --fees 400000000nhash | jq
${PIO_CMD} tx marker grant ${VALIDATOR_ID} usd.local mint,burn,admin,withdraw,deposit --from validator \
    ${COMMON_TX_FLAGS} --fees 400000000nhash| jq
${PIO_CMD} tx marker finalize usd.local --from validator \
    ${COMMON_TX_FLAGS} --fees 400000000nhash| jq
${PIO_CMD} tx marker activate usd.local --from validator \
    ${COMMON_TX_FLAGS} --fees 400000000nhash|  jq
${PIO_CMD} tx marker withdraw usd.local 1000usd.local ${VALIDATOR_ID}  \
    --from validator \
    ${COMMON_TX_FLAGS} --fees 400000000nhash | jq
${PIO_CMD} q bank balances ${VALIDATOR_ID} -o json | jq '.balances[]| select(.denom =="usd.local") | .amount | tonumber'

echo "Updating msgfee for msg sends to usd"
${PIO_CMD} tx msgfees proposal update "updating" "updating msgsend fee"  10000000000nhash --msg-type "${MSG_TYPE}" --additional-fee 5usd.local  --from validator  --fees 1000000000nhash ${COMMON_TX_FLAGS} | jq > ${GEN_TMP_DIR}/update-proposal.json
PROPOSAL_ID=$(cat ${GEN_TMP_DIR}/update-proposal.json | jq ' .logs[0].events[] | select(.type=="submit_proposal") | .attributes[] | select(.key=="proposal_id") | .value | tonumber')
echo "Voting proposal id ${PROPOSAL_ID} for additional fees for msg sends $(${PIO_CMD} tx gov vote ${PROPOSAL_ID} yes --from validator --fees 1000000000nhash ${COMMON_TX_FLAGS} | jq '.code | tonumber' )"
echo "Sleeping for voting period time to elapse"
sleep 6
echo "List new msg based fees...should contain new msg type fee"
${PIO_CMD} q msgfees list -o json | jq 


echo "Generating send...to be used for simulate tx"
${PIO_CMD} tx bank send ${VALIDATOR_ID} ${SELLER} 100000000000nhash  \
    --from validator --generate-only | jq > ${GEN_TMP_DIR}/tmp.generated.send.json
echo "Signing send....to be used for simulate tx"
${PIO_CMD} tx sign ${GEN_TMP_DIR}/tmp.generated.send.json --from ${VALIDATOR_ID} ${COMMON_TX_FLAGS} | jq> ${GEN_TMP_DIR}/tmp.generated.send.json.signed
echo "Run Simulate through custom pio simulate to capture any additional fees using gas adjustment ${GAS_ADJUSTMENT}"
${PIO_CMD} tx simulate ${GEN_TMP_DIR}/tmp.generated.send.json.signed ${COMMON_TX_FLAGS} --from ${VALIDATOR_ID} ${GAS_ADJUSTMENT} | jq > ${GEN_TMP_DIR}/simulate.response.json
cat ${GEN_TMP_DIR}/simulate.response.json 
TOTAL_FEES=$(cat test-tmp/simulate.response.json | jq '.total_fees[] | .amount+.denom ' | tr -d '"' | paste -s -d, -)
echo "Estimated total fee $TOTAL_FEES"
ESTIMTATED_GAS=$(cat ${GEN_TMP_DIR}/simulate.response.json  | jq '.estimated_gas | tonumber')
echo "Estimated gas $ESTIMTATED_GAS"
${PIO_CMD} tx bank send ${VALIDATOR_ID} ${SELLER} 100000000000nhash  \
    --from validator ${COMMON_TX_FLAGS} --gas ${ESTIMTATED_GAS} --fees ${TOTAL_FEES} | jq
${PIO_CMD} q bank balances ${VALIDATOR_ID} -o json | jq

# rm -rf ${GEN_TMP_DIR}