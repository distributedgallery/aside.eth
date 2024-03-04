#!/bin/bash

source .env

if [ $# != 1 ]; then
  echo "Please provide a token id."
  exit 1
fi

forge script --account DistributedGallery --froms 0x3c7e48216C74D7818aB1Fd226e56C60C4D659bA6 --sender 0x3c7e48216C74D7818aB1Fd226e56C60C4D659bA6 --broadcast --rpc-url sepolia script/Aside0x01.transfer.s.sol --sig "run(address,uint256)" $SEPOLIA_ADDRESS $1
exit 0
