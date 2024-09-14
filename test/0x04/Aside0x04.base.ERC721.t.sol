// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.25;

import {Aside0x04TestHelper} from "./Aside0x04TestHelper.t.sol";
import {AsideBaseERC721Test} from "../helpers/AsideBase/tests/ERC721/AsideBase.ERC721.t.sol";

contract Aside0x04BaseERC721Test is Aside0x04TestHelper, AsideBaseERC721Test {
    function test_metadata() public {
        assertEq(baseToken.name(), "FELL-CLOUD");
        assertEq(baseToken.symbol(), "FELL-CLOUD");
    }
}
