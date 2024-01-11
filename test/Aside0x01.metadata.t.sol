// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {TestHelper} from "./Aside0x01Helper.sol";

contract Metadata is TestHelper {
    function test_Metadata() public {
        assertEq(token.name(), "Aside0x01");
        assertEq(token.symbol(), "ASD");
    }
}
