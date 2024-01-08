// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Aside0x01} from "../src/Aside01.sol";
import {TestHelper} from "./Aside0x01Helper.sol";

contract Aside01Test is TestHelper {
    function test_Deploy() public {
        assertEq(token.name(), "Aside0x01");
        assertEq(token.symbol(), "ASD");
    }
}
