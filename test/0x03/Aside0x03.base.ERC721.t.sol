// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.25;

import {Aside0x03TestHelper} from "./Aside0x03TestHelper.t.sol";
import {AsideBaseERC721Test} from "../helpers/AsideBase/tests/ERC721/AsideBase.ERC721.t.sol";

contract Aside0x03BaseERC721Test is Aside0x03TestHelper, AsideBaseERC721Test {
    function test_metadata() public {
        assertEq(baseToken.name(), "10K Drop");
        assertEq(baseToken.symbol(), "10K");
    }
}
