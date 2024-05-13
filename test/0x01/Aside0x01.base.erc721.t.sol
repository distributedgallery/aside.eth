// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.25;

import {Aside0x01TestHelper} from "./Aside0x01TestHelper.t.sol";
import {AsideBaseERC721Test} from "../helpers/AsideBase/tests/ERC721/AsideBase.ERC721.t.sol";

contract Aside0x01BaseERC721Test is Aside0x01TestHelper, AsideBaseERC721Test {
    function test_metadata() public {
        assertEq(baseToken.name(), "Aside0x01");
        assertEq(baseToken.symbol(), "ASD0x01");
    }
}
