// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import "forge-std/Script.sol";
import {Aside0x01} from "../src/Aside0x01.sol";

contract Aside0x01Transfer is Script {
    function run(address deployed, uint256 tokenId) external {
        vm.startBroadcast();
        Aside0x01 token = Aside0x01(deployed);
        token.safeTransferFrom(token.ownerOf(tokenId), 0x8873b045d40A458e46E356a96279aE1820a898bA, tokenId);
        vm.stopBroadcast();
    }
}
