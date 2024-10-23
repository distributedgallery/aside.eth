// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.25;

import {Aside0x05, Aside0x05TestHelper} from "./Aside0x05TestHelper.t.sol";
import {AsideChainlinkTest} from "../helpers/AsideChainlink/tests/AsideChainlink.t.sol";

contract Result is Aside0x05TestHelper, AsideChainlinkTest {
    function test_result_WhenNoOneHasBeenElected() public {
        assertEq(token.result(), 3);
    }

    function test_result_WhenHarrisHasBeenElected() public setUpUnlockConditions(0) {
        assertEq(token.result(), 0);
    }

    function test_result_WhenTrumpHasBeenElected() public setUpUnlockConditions(1) {
        assertEq(token.result(), 1);
    }
}
