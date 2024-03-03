// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import "forge-std/Script.sol";
import {Aside0x01} from "../src/Aside0x01.sol";

contract Aside0x01Unlock is Script {
    address public deployed = 0x0677d658D57910B33106a111C65B902D0cA3e000;

    function run() external {
        vm.startBroadcast();

        Aside0x01 token = Aside0x01(deployed);
        token.unlock(1_132_259_709);

        vm.stopBroadcast();
    }
}
