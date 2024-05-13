// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import "forge-std/Script.sol";
import {Aside0x01} from "../src/Aside0x01.sol";

contract Aside0x01Mint is Script {
    function run(address deployed, address receiver) external {
        vm.startBroadcast();
        Aside0x01 token = Aside0x01(deployed);
        for (uint256 i = 0; i < 110; i++) {
            token.mint(receiver, i);
        }
        vm.stopBroadcast();
    }
}
