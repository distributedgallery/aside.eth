#!/bin/bash

source .env

if [ $# != 3 ]; then
  echo "Please provide a network name [mainnet or sepolia], a token id and a sentiment."
  exit 1
fi

if [ "$1" == "sepolia" ]; then
  forge script --account DistributedGallery --froms 0x3c7e48216C74D7818aB1Fd226e56C60C4D659bA6 --sender 0x3c7e48216C74D7818aB1Fd226e56C60C4D659bA6 --broadcast --rpc-url sepolia script/Aside0x01.mint.s.sol --sig "run(address,uint256,string memory)" $SEPOLIA_ADDRESS $2 $3
  exit 0
elif [ "$1" == "mainnet" ]; then
  echo 'coming soon'
  exit 0
else
  echo "Unsupported network: $1."
  exit 1
fi
