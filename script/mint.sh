#!/bin/bash

source .env

forge script --account DistributedGallery --froms 0x3c7e48216C74D7818aB1Fd226e56C60C4D659bA6 --sender 0x3c7e48216C74D7818aB1Fd226e56C60C4D659bA6 --broadcast --rpc-url sepolia script/Aside0x01.mint.s.sol --sig "run(address,address)" $SEPOLIA_ADDRESS $SEPOLIA_RECEIVER
exit 0
