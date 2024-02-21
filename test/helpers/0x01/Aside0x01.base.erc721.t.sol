// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import {Aside0x01TestHelper, AsideBaseTestHelper, AsideChainlinkTestHelper, Aside0x01} from "./Aside0x01TestHelper.t.sol";
import {AsideBaseERC721Test} from "../AsideBase/tests/ERC721/AsideBase.ERC721.t.sol";

contract Aside0x01ChainlinkTest is AsideBaseERC721Test, Aside0x01TestHelper {
    function _mint() internal override(Aside0x01TestHelper, AsideBaseTestHelper) {
        super._mint();
    }
}
