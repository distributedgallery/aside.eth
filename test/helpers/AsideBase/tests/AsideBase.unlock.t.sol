// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import {AsideBaseTestHelper, AsideBase, IERC721Errors, IAccessControl} from "../AsideBaseTestHelper.t.sol";

abstract contract Unlock is AsideBaseTestHelper {
    function test_unlock() public mint setUpUnlockConditions {
        vm.expectEmit(address(baseToken));
        emit AsideBase.Unlock(tokenId);

        baseToken.unlock(_tokenIds());

        assertTrue(baseToken.isUnlocked(tokenId));
    }

    function test_RevertWhen_unlock_ForNonexistentToken() public {
        vm.expectRevert(abi.encodeWithSelector(IERC721Errors.ERC721NonexistentToken.selector, tokenId));
        baseToken.unlock(_tokenIds());
    }

    function test_RevertWhen_unlock_ForAlreadyUnlockedToken() public mint unlock {
        vm.expectRevert(abi.encodeWithSelector(AsideBase.TokenAlreadyUnlocked.selector, tokenId));
        baseToken.unlock(_tokenIds());
    }
}
