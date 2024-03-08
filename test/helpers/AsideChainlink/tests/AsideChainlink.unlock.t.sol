// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import {AsideChainlinkTestHelper, AsideChainlink, AsideBase, IERC721Errors, IAccessControl} from "../AsideChainlinkTestHelper.t.sol";

abstract contract Unlock is AsideChainlinkTestHelper {
    function test_unlock() public mint {
        vm.prank(unlocker);
        chainlinkToken.unlock(_tokenIds());
        uint256[] memory tokenIds = chainlinkToken.tokenIdsOf(router.REQUEST_ID());
        assertEq(tokenIds.length, 1);
        assertEq(tokenIds[0], tokenId);
    }

    function test_RevertWhen_unlock_ForEmptyTokenIds() public {
        uint256[] memory tokenIds;
        vm.expectRevert(abi.encodeWithSelector(AsideChainlink.InvalidTokenIds.selector));
        vm.prank(unlocker);
        chainlinkToken.unlock(tokenIds);
    }

    function test_RevertWhen_unlock_ForNonexistentToken() public {
        vm.expectRevert(abi.encodeWithSelector(IERC721Errors.ERC721NonexistentToken.selector, tokenId));
        vm.prank(unlocker);
        chainlinkToken.unlock(_tokenIds());
    }

    function test_RevertWhen_unlock_ForAlreadyUnlockedToken() public mint unlock {
        vm.expectRevert(abi.encodeWithSelector(AsideBase.TokenAlreadyUnlocked.selector, tokenId));
        vm.prank(unlocker);
        chainlinkToken.unlock(_tokenIds());
    }

    function test_RevertWhen_unlock_FromUnauthorized() public mint {
        vm.expectRevert(
            abi.encodeWithSelector(IAccessControl.AccessControlUnauthorizedAccount.selector, address(this), baseToken.UNLOCKER_ROLE())
        );
        chainlinkToken.unlock(_tokenIds());
    }
}
