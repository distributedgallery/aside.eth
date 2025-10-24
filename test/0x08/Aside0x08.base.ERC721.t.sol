// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.25;

import {Aside0x08TestHelper} from "./Aside0x08TestHelper.t.sol";
import {Aside0x08ERC721Test} from "./ERC721/AsideBase.ERC721.t.sol";

contract Aside0x08BaseERC721Test is Aside0x08TestHelper, Aside0x08ERC721Test {
    function test_metadata() public {
        assertEq(token.name(), "Good Bye");
        assertEq(token.symbol(), "GDBY");
    }
}
