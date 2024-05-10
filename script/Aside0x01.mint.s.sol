// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import "forge-std/Script.sol";
import {Aside0x01} from "../src/Aside0x01.sol";

contract Aside0x01Mint is Script {
    function run(address deployed, address receiver) external {
        vm.startBroadcast();
        Aside0x01 token = Aside0x01(deployed);
        for (uint256 i = 0; i < 10; i++) {
            token.mint(receiver, i, "070");
        }

        for (uint256 i = 10; i < 20; i++) {
            token.mint(receiver, i, "080");
        }

        for (uint256 i = 20; i < 30; i++) {
            token.mint(receiver, i, "090");
        }
        vm.stopBroadcast();
    }
}
