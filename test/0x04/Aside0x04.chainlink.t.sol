// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.25;

import {Aside0x04, Aside0x04TestHelper} from "./Aside0x04TestHelper.t.sol";
import {AsideChainlinkTest} from "../helpers/AsideChainlink/tests/AsideChainlink.t.sol";

contract Aside0x04ChainlinkTest is Aside0x04TestHelper, AsideChainlinkTest {
    function test_RevertWhen_update_WhenAleadyUnlocked() public setUpUnlockConditions {
        vm.prank(updater);
        vm.expectRevert(abi.encodeWithSelector(Aside0x04.AlreadyUnlocked.selector));
        token.update(new string[](0));
    }
}
