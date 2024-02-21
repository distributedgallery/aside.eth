// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import {Aside0x01TestHelper, AsideBaseTestHelper} from "./Aside0x01TestHelper.t.sol";
import {AsideChainlinkTest} from "../helpers/AsideChainlink/tests/AsideChainlink.t.sol";

contract Aside0x01ChainlinkTest is Aside0x01TestHelper, AsideChainlinkTest {
    function _mint() internal override(Aside0x01TestHelper, AsideBaseTestHelper) {
        super._mint();
    }
}
