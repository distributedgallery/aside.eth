// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.25;

import {Aside0x02TestHelper} from "./Aside0x02TestHelper.t.sol";
import {AsideBaseERC721Test} from "../helpers/AsideBase/tests/ERC721/AsideBase.ERC721.t.sol";

contract Aside0x02BaseERC721Test is Aside0x02TestHelper, AsideBaseERC721Test {
    function test_metadata() public {
        assertEq(baseToken.name(), "Ray Marching the Moon: Full & New");
        assertEq(baseToken.symbol(), "MOON");
    }
}
