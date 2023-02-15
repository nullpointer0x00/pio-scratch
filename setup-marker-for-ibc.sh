#!/bin/bash


PROVENANCE_DEV_DIR=~/code/provenance
#${PROVENANCE_DEV_DIR}/build/provenanced -t --home ${PROVENANCE_DEV_DIR}/build/run/provenance keys add ownermarker --recover --hd-path "44'/118'/0'/0/0" --keyring-backend test < ./mnemonics/merchant.txt
COMMON_TX_FLAGS="--gas auto --gas-prices 0vspn --gas-adjustment 2 --chain-id jackthecat --keyring-backend test --yes -o json"

#  ${PROVENANCE_DEV_DIR}/build/provenanced tx bank send \
#   $(${PROVENANCE_DEV_DIR}/build/provenanced keys show -a validator --home ${PROVENANCE_DEV_DIR}/build/run/provenanced --keyring-backend test --testnet) \
#   $(${PROVENANCE_DEV_DIR}/build/provenanced keys show -a ownermarker --home ${PROVENANCE_DEV_DIR}/build/run/provenanced --keyring-backend test --testnet) \
#   1000000000000vspn \
#   --from validator \
#   --home ${PROVENANCE_DEV_DIR}/build/run/provenanced \
#   --keyring-backend test --chain-id jackthecat --gas auto --gas-prices 0vspn --gas-adjustment 2 --broadcast-mode block --yes \
#   --testnet -o json | jq

# ${PROVENANCE_DEV_DIR}/build/provenanced -t --home ${PROVENANCE_DEV_DIR}/build/run/provenanced \
#      tx marker new 0kerrithecat \
#     --type RESTRICTED \
#     --from validator \
#     --fees 100000000000vspn --chain-id jackthecat --keyring-backend test --yes -o json | jq

${PROVENANCE_DEV_DIR}/build/provenanced -t tx marker grant \
    $(${PROVENANCE_DEV_DIR}/build/provenanced keys show -a validator --home ${PROVENANCE_DEV_DIR}/build/run/provenanced --keyring-backend test --testnet) \
    kerrithecat \
    admin,burn,deposit,delete,mint,withdraw,transfer \
    --from validator \
     --home ${PROVENANCE_DEV_DIR}/build/run/provenanced \
     --fees 0vspn --chain-id jackthecat --keyring-backend test --yes -o json | jq


# ${PROVENANCE_DEV_DIR}/build/provenanced -t tx marker finalize kerrithecat \
#     --from validator \
#     --keyring-backend test \
#     --home ${PROVENANCE_DEV_DIR}/build/run/provenanced \
#      --fees 0vspn --chain-id jackthecat --keyring-backend test --yes -o json | jq

# ${PROVENANCE_DEV_DIR}/build/provenanced -t  tx marker activate kerrithecat \
#     --from validator \
#     --keyring-backend test \
#     --home ${PROVENANCE_DEV_DIR}/build/run/provenanced \
#      --fees 0vspn --chain-id jackthecat --keyring-backend test --yes -o json | jq

# ${PROVENANCE_DEV_DIR}/build/provenanced -t tx marker mint 200000kerrithecat \
#     --from validator \
#     --keyring-backend test \
#     --home ${PROVENANCE_DEV_DIR}/build/run/provenanced \
#      --fees 0vspn --chain-id jackthecat --keyring-backend test --yes -o json | jq

# ${PROVENANCE_DEV_DIR}/build/provenanced -t tx marker withdraw kerrithecat 100000kerrithecat $(${PROVENANCE_DEV_DIR}/build/provenanced keys show -a validator --home ${PROVENANCE_DEV_DIR}/build/run/provenanced --keyring-backend test --testnet) \
#         --from validator \
#         --keyring-backend test \
#         --home ${PROVENANCE_DEV_DIR}/build/run/provenanced \
#      --fees 0vspn --chain-id jackthecat --keyring-backend test --yes -o json | jq


# ${PROVENANCE_DEV_DIR}/build/provenanced -t tx marker withdraw kerrithecat 100000kerrithecat tp1t6urmuke2r2qnv23ts0t3qjp65ffp2vc529y0j \
#         --from validator \
#         --keyring-backend test \
#         --home ${PROVENANCE_DEV_DIR}/build/run/provenanced \
#      --fees 0vspn --chain-id jackthecat --keyring-backend test --yes -o json | jq