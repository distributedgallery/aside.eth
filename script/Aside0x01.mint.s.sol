// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import "forge-std/Script.sol";
import {Aside0x01} from "../src/Aside0x01.sol";

contract Aside0x01Mint is Script {
    // uint256 tokenId = 1132259709;
    function run(address deployed, uint256 tokenId, string memory sentiment) external {
        vm.startBroadcast();
        Aside0x01 token = Aside0x01(deployed);
        token.mint(0x8873b045d40A458e46E356a96279aE1820a898bA, tokenId, sentiment);
        vm.stopBroadcast();
    }
}
