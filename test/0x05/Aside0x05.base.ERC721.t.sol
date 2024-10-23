// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.25;

import {Aside0x05TestHelper} from "./Aside0x05TestHelper.t.sol";
import {AsideBaseERC721Test} from "../helpers/AsideBase/tests/ERC721/AsideBase.ERC721.t.sol";

contract Aside0x05BaseERC721Test is Aside0x05TestHelper, AsideBaseERC721Test {
    function test_metadata() public {
        assertEq(baseToken.name(), "What Can Be");
        assertEq(baseToken.symbol(), "WCB");
    }
}
