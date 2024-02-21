// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import {AsideBaseTestHelper, IERC721Errors} from "../../AsideBaseTestHelper.t.sol";

abstract contract TokenURI is AsideBaseTestHelper {
    function test_tokenURI() public mint {
        assertEq(baseToken.tokenURI(tokenId), tokenURI);
    }

    function test_RevertWhen_tokenURI_ForNonexistentToken() public {
        vm.expectRevert(abi.encodeWithSelector(IERC721Errors.ERC721NonexistentToken.selector, tokenId));
        baseToken.tokenURI(tokenId);
    }
}
