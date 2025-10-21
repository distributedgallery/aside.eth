// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.25;

import {Aside0x08, AsideBase, Aside0x08TestHelper} from "./Aside0x08TestHelper.t.sol";
import {AsideBaseTest} from "../helpers/AsideBase/tests/AsideBase.t.sol";

contract Aside0x08BaseTest is Aside0x08TestHelper, AsideBaseTest {
    // #region NB_OF_TOKENS
    function test_NB_OF_TOKENS() public {
        assertEq(baseToken.NB_OF_TOKENS(), 81);
    }

    // #endregion

    // #region unlock
    function test_RevertWhen_unlock() public mint {
        vm.expectRevert(
            abi.encodeWithSelector(Aside0x08.DisabledFunction.selector)
        );
        baseToken.unlock(_tokenIds());
    }

    // #endregion

    // #region overrides
    function test_RevertWhen_unlock_ForNonexistentToken()
        public
        virtual
        override
    {}

    function test_RevertWhen_unlock_ForAlreadyUnlockedToken()
        public
        virtual
        override
    {}
    // #endregion
}
