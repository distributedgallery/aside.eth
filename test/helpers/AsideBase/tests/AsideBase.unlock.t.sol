// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.25;

import {AsideBase, AsideBaseTestHelper, IERC721Errors} from "../AsideBaseTestHelper.t.sol";

abstract contract Unlock is AsideBaseTestHelper {
    function test_RevertWhen_unlock_ForNonexistentToken() public {
        vm.expectRevert(abi.encodeWithSelector(IERC721Errors.ERC721NonexistentToken.selector, tokenId));
        baseToken.unlock(_tokenIds());
    }

    function test_RevertWhen_unlock_ForAlreadyUnlockedToken() public mint unlock {
        vm.expectRevert(abi.encodeWithSelector(AsideBase.TokenAlreadyUnlocked.selector, tokenId));
        baseToken.unlock(_tokenIds());
    }
}
