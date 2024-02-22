#!/bin/bash

if [ $# -eq 0 ]
  then
    echo "Please provide a network name: mainnet or sepolia."
  else
    if [ "$1" == "sepolia" ]
    then
      forge script --account DistributedGallery --froms 0x3c7e48216C74D7818aB1Fd226e56C60C4D659bA6 --sender 0x3c7e48216C74D7818aB1Fd226e56C60C4D659bA6 --broadcast --rpc-url sepolia --verify --delay 20 script/Aside0x01.s.sol
    elif [ "$1" == "mainnet" ]
    then
        echo 'coming soon'
    else
        echo "Unsupported network: $1"
    fi
fi
