// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.25;

import "forge-std/Script.sol";
import {Aside0x05} from "../src/Aside0x05.sol";

contract Aside0x05Deploy is Script {
    function run(
        string memory baseUri,
        address admin,
        address minter,
        address updater,
        address verse,
        uint256 timelock,
        address router,
        bytes32 donId,
        uint64 subscriptionId,
        uint32 callbackGasLimit,
        string memory source
    ) external {
        vm.startBroadcast();
        new Aside0x05(baseUri, admin, minter, updater, verse, timelock, router, donId, subscriptionId, callbackGasLimit, source);
        vm.stopBroadcast();
    }
}
