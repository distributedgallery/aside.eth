// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.25;

import "forge-std/Script.sol";
import {Aside0x01} from "../src/Aside0x01.sol";

contract Aside0x01Update is Script {
    function run(address deployed) external {
        vm.startBroadcast();
        Aside0x01 token = Aside0x01(deployed);
        string[] memory args;
        token.update(args);
    }
}
