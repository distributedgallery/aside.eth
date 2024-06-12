#!/bin/bash

source .env


if [ $# == 0 ]; then
  echo "Please provide a network name [mainnet or sepolia]."
  exit 1
fi

if [ "$1" == "sepolia" ]; then
  forge script --legacy --account DistributedGallery --froms 0x3c7e48216C74D7818aB1Fd226e56C60C4D659bA6 --sender 0x3c7e48216C74D7818aB1Fd226e56C60C4D659bA6 --broadcast --rpc-url sepolia script/Aside0x01.unlock.s.sol --sig "run(address)" $SEPOLIA_ADDRESS
  exit 0
elif [ "$1" == "mainnet" ]; then
  forge script --legacy --account DistributedGallery --froms 0x3c7e48216C74D7818aB1Fd226e56C60C4D659bA6 --sender 0x3c7e48216C74D7818aB1Fd226e56C60C4D659bA6 --broadcast --rpc-url mainnet script/Aside0x01.unlock.s.sol --sig "run(address)" $MAINNET_ADDRESS
  exit 0
else
  echo "Unsupported network: $1."
  exit 1
fi