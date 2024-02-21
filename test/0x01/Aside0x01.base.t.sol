// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import {Aside0x01TestHelper, AsideBaseTestHelper} from "./Aside0x01TestHelper.t.sol";
import {AsideBaseTest} from "../helpers/AsideBase/tests/AsideBase.t.sol";

contract Aside0x01BaseTest is Aside0x01TestHelper, AsideBaseTest {
    function _mint() internal override(Aside0x01TestHelper, AsideBaseTestHelper) {
        super._mint();
    }

    function _mint(address to) internal override(Aside0x01TestHelper, AsideBaseTestHelper) {
        super._mint(to);
    }

    function test_isUnlocked_WhenRegularUnlockHasBeenTriggered() public mint {
        token.requestUnlock(tokenId);
        router.fulfillRequest(token, abi.encodePacked(sentiment), "");
        assertTrue(token.isUnlocked(tokenId));
    }
}
