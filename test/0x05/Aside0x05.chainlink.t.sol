// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.25;

import {Aside0x05, Aside0x05TestHelper} from "./Aside0x05TestHelper.t.sol";
import {AsideChainlinkTest} from "../helpers/AsideChainlink/tests/AsideChainlink.t.sol";

contract Aside0x05ChainlinkTest is Aside0x05TestHelper, AsideChainlinkTest {
    function test_RevertWhen_update_WhenAleadyUnlocked() public setUpUnlockConditions(0) {
        vm.prank(updater);
        vm.expectRevert(abi.encodeWithSelector(Aside0x05.AlreadyUnlocked.selector));
        token.update(new string[](0));
    }
}
