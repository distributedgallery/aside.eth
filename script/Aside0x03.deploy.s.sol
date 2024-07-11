// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.25;

import "forge-std/Script.sol";
import {Aside0x03} from "../src/Aside0x03.sol";

contract Aside0x03Deploy is Script {
    function run(string memory baseUri, address admin, address minter, address verse, uint256 timelock, address feed) external {
        vm.startBroadcast();
        new Aside0x03(baseUri, admin, minter, verse, timelock, feed);
        vm.stopBroadcast();
    }
}
