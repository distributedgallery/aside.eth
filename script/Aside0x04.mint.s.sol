// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import "forge-std/Script.sol";
import {Aside0x04} from "../src/Aside0x04.sol";

contract Aside0x04Mint is Script {
    function run(address deployed, address receiver) external {
        vm.startBroadcast();
        Aside0x04 token = Aside0x04(deployed);
        for (uint256 i = 0; i < 30; i++) {
            token.mint(receiver, i);
        }
        vm.stopBroadcast();
    }
}
