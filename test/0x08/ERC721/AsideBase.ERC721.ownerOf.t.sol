// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.25;

import {Aside0x08TestHelper, IERC721Errors} from "../Aside0x08TestHelper.t.sol";

abstract contract OwnerOf is Aside0x08TestHelper {
    function test_ownerOf() public mint {
        assertEq(token.ownerOf(tokenId), owner);
    }

    function test_RevertWhen_ownerOf_ForNonexistentToken() public {
        vm.expectRevert(
            abi.encodeWithSelector(
                IERC721Errors.ERC721NonexistentToken.selector,
                tokenId
            )
        );
        token.ownerOf(tokenId);
    }
}
