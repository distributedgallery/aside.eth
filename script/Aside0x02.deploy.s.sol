// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.25;

import "forge-std/Script.sol";
import {Aside0x02} from "../src/Aside0x02.sol";

contract Aside0x02Deploy is Script {
    function run(string memory baseUri, address admin, address minter, address verse, uint256 timelock) external {
        vm.startBroadcast();
        new Aside0x02(baseUri, admin, minter, verse, timelock);
        vm.stopBroadcast();
    }
}
