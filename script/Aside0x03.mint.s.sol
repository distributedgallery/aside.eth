// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import "forge-std/Script.sol";
import {Aside0x03} from "../src/Aside0x03.sol";

contract Aside0x03Mint is Script {
    function run(address deployed, address receiver) external {
        vm.startBroadcast();
        Aside0x03 token = Aside0x03(deployed);
        token.mint(receiver, 2);
        vm.stopBroadcast();
    }
}
