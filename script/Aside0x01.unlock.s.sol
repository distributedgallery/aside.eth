// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import "forge-std/Script.sol";
import {Aside0x01} from "../src/Aside0x01.sol";

contract Aside0x01Unlock is Script {
    function run(address deployed, uint256 tokenId) external {
        vm.startBroadcast();
        Aside0x01 token = Aside0x01(deployed);
        uint256[] memory tokenIds = new uint256[](1);
        tokenIds[0] = tokenId;
        token.unlock(tokenIds);
        vm.stopBroadcast();
    }
}
