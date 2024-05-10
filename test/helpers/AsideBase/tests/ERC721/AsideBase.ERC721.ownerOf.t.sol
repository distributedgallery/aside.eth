// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.25;

import {AsideBaseTestHelper, IERC721Errors} from "../../AsideBaseTestHelper.t.sol";

abstract contract OwnerOf is AsideBaseTestHelper {
    function test_ownerOf() public mint {
        assertEq(baseToken.ownerOf(tokenId), owner);
    }

    function test_RevertWhen_ownerOf_ForNonexistentToken() public {
        vm.expectRevert(abi.encodeWithSelector(IERC721Errors.ERC721NonexistentToken.selector, tokenId));
        baseToken.ownerOf(tokenId);
    }
}
