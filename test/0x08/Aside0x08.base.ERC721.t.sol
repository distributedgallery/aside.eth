// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.25;

import {Aside0x08TestHelper} from "./Aside0x08TestHelper.t.sol";
import {AsideBaseERC721Test} from "../helpers/AsideBase/tests/ERC721/AsideBase.ERC721.t.sol";

contract Aside0x08BaseERC721Test is Aside0x08TestHelper, AsideBaseERC721Test {
    function test_metadata() public {
        assertEq(baseToken.name(), "Goodbye");
        assertEq(baseToken.symbol(), "GDBY");
    }
}
