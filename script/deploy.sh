#!/bin/bash

source .env

if [ $# == 0 ]; then
  echo "Please provide a network name [mainnet or sepolia]."
  exit 1
fi

if [ "$1" == "sepolia" ]; then
  forge script --legacy --account DistributedGallery --froms 0x3c7e48216C74D7818aB1Fd226e56C60C4D659bA6 --sender 0x3c7e48216C74D7818aB1Fd226e56C60C4D659bA6 --broadcast --rpc-url sepolia --verify --delay 20 script/Aside0x04.deploy.s.sol --sig "run(string memory,address,address,address,uint256)" $BASE_URI_0x04 $SEPOLIA_ADMIN $SEPOLIA_MINTER $SEPOLIA_VERSE $SEPOLIA_TIMELOCK
  exit 0
elif [ "$1" == "mainnet" ]; then
  forge script --legacy --account DistributedGallery --froms 0x3c7e48216C74D7818aB1Fd226e56C60C4D659bA6 --sender 0x3c7e48216C74D7818aB1Fd226e56C60C4D659bA6 --broadcast --rpc-url mainnet --verify --delay 20 script/Aside0x04.deploy.s.sol --sig "run(string memory,address,address,address,uint256)" $BASE_URI_0x04 $ADMIN $MINTER $VERSE $TIMELOCK
  exit 0
else
  echo "Unsupported network: $1."
  exit 1
fi
