// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import {Aside0x01TestHelper, AsideBaseTestHelper} from "./Aside0x01TestHelper.t.sol";
import {AsideBaseERC721Test} from "../helpers/AsideBase/tests/ERC721/AsideBase.ERC721.t.sol";

contract Aside0x01BaseERC721Test is Aside0x01TestHelper, AsideBaseERC721Test {
    function _mint() internal override(Aside0x01TestHelper, AsideBaseTestHelper) {
        super._mint();
    }

    function _mint(address to) internal override(Aside0x01TestHelper, AsideBaseTestHelper) {
        super._mint(to);
    }

    function _setUpUnlockConditions() internal override(Aside0x01TestHelper, AsideBaseTestHelper) {
        super._setUpUnlockConditions();
    }

    function test_metadata() public {
        assertEq(baseToken.name(), "Aside0x01");
        assertEq(baseToken.symbol(), "ASD0x01");
    }
}
