// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import "forge-std/Script.sol";
import {Aside0x02} from "../src/Aside0x02.sol";

contract Aside0x02Mint is Script {
    function run(address deployed, address receiver) external {
        vm.startBroadcast();
        Aside0x02 token = Aside0x02(deployed);
        for (uint256 i = 0; i < 10; i++) {
            token.mint(receiver, i);
        }
        // for (uint256 i = 69; i < 119; i++) {
        //     token.mint(receiver, i);
        // }

        vm.stopBroadcast();
    }
}
