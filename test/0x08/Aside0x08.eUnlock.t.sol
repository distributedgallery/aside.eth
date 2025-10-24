// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.25;

import {Aside0x08, Aside0x08TestHelper, IAccessControl} from "./Aside0x08TestHelper.t.sol";
import {AsideBaseTest} from "../helpers/AsideBase/tests/AsideBase.t.sol";

contract EUnlock is Aside0x08TestHelper {
    event BatchMetadataUpdate(uint256 _fromTokenId, uint256 _toTokenId);

    function test_eUnlock() public {
        // vm.expectEmit(address(token));
        // emit BatchMetadataUpdate(0, 81);
        // emit EmergencyUnlock();
        // vm.prank(admin);
        // token.eUnlock();
        // assertTrue(token.isEUnlocked());
    }

    function test_RevertWhen_eUnlock_FromUnauthorized() public {
        // vm.expectRevert(
        //     abi.encodeWithSelector(
        //         IAccessControl.AccessControlUnauthorizedAccount.selector,
        //         address(this),
        //         token.DEFAULT_ADMIN_ROLE()
        //     )
        // );
        // token.eUnlock();
    }
}
