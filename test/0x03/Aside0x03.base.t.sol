// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.25;

import {Aside0x03, Aside0x03TestHelper} from "./Aside0x03TestHelper.t.sol";
import {AsideBaseTest} from "../helpers/AsideBase/tests/AsideBase.t.sol";

contract Aside0x03BaseTest is Aside0x03TestHelper, AsideBaseTest {
    // #region NB_OF_TOKENS
    function test_NB_OF_TOKENS() public {
        assertEq(baseToken.NB_OF_TOKENS(), 100);
    }
    // #endregion

    // #region unlock
    function test_RevertWhen_unlock() public {
        vm.expectRevert(abi.encodeWithSelector(Aside0x03.DisabledFunction.selector));
        baseToken.unlock(_tokenIds());
    }

    function test_RevertWhen_unlock_ForAlreadyUnlockedToken() public override {}

    function test_RevertWhen_unlock_ForNonexistentToken() public override {}
    // #endregion
}
