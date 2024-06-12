// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.25;

import "forge-std/Script.sol";
import {Aside0x01} from "../src/Aside0x01.sol";

contract Aside0x01Unlock is Script {
    function run(address deployed) external {
        vm.startBroadcast();
        Aside0x01 token = Aside0x01(deployed);
        uint256[] memory tokenIds = new uint256[](1);
        tokenIds[0] = 100;
        // tokenIds[1] = 61;
        // tokenIds[2] = 62;
        // tokenIds[3] = 63;
        // tokenIds[4] = 64;
        // tokenIds[5] = 65;
        // tokenIds[6] = 66;
        // tokenIds[7] = 67;
        // tokenIds[8] = 68;
        // tokenIds[9] = 69;
        token.unlock(tokenIds);
        vm.stopBroadcast();
    }
}
