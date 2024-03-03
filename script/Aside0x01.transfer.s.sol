// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import "forge-std/Script.sol";
import {Aside0x01} from "../src/Aside0x01.sol";

contract Aside0x01Transfer is Script {
    address public deployed = 0x0677d658D57910B33106a111C65B902D0cA3e000;

    function run() external {
        vm.startBroadcast();

        uint256 tokenId = 1_079_843_793;
        Aside0x01 token = Aside0x01(deployed);
        token.safeTransferFrom(token.ownerOf(tokenId), 0x8873b045d40A458e46E356a96279aE1820a898bA, tokenId);

        vm.stopBroadcast();
    }
}
