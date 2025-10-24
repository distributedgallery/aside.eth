// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.25;

import {Aside0x08, Aside0x08TestHelper, IAccessControl} from "./Aside0x08TestHelper.t.sol";
import {AsideBaseTest} from "../helpers/AsideBase/tests/AsideBase.t.sol";

contract Aside0x08BaseTest is Aside0x08TestHelper {
    event BatchMetadataUpdate(uint256 _fromTokenId, uint256 _toTokenId);
    event Unlock();

    function test_NB_OF_TOKENS() public {
        assertEq(token.NB_OF_TOKENS(), 81);
    }

    function test_unlock() public {
        assertFalse(token.isUnlocked());
        vm.expectEmit(address(token));
        emit BatchMetadataUpdate(0, type(uint256).max);
        emit Unlock();
        vm.prank(admin);
        token.unlock();
        assertTrue(token.isUnlocked());
    }

    function test_RevertWhen_unlock_WhenAlreadyUnlocked() public unlock {
        vm.expectRevert(
            abi.encodeWithSelector(Aside0x08.AlreadyUnlocked.selector)
        );
        vm.prank(admin);
        token.unlock();
    }

    function test_RevertWhen_unlock_FromUnauthorized() public {
        vm.expectRevert(
            abi.encodeWithSelector(
                IAccessControl.AccessControlUnauthorizedAccount.selector,
                address(this),
                token.DEFAULT_ADMIN_ROLE()
            )
        );
        token.unlock();
    }

    // #endregion
}
