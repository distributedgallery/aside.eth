// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import "forge-std/Script.sol";
import {Aside0x01} from "../src/Aside0x01.sol";

contract Aside0x01Deploy is Script {
    function run(
        string memory baseUri,
        address admin,
        address minter,
        address unlocker,
        address verse,
        uint256 timelock,
        address router,
        bytes32 donId,
        uint64 subscriptionId,
        uint32 callbackGasLimit,
        string memory source
    ) external {
        vm.startBroadcast();
        new Aside0x01(baseUri, admin, minter, unlocker, verse, timelock, router, donId, subscriptionId, callbackGasLimit, source);
        vm.stopBroadcast();
    }
}
