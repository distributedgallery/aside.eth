// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.25;

import {Aside0x08TestHelper, IERC721Errors} from "../Aside0x08TestHelper.t.sol";

abstract contract TokenURI is Aside0x08TestHelper {
    function test_tokenURI_BeforeDeath() public mint {
        assertEq(token.tokenURI(tokenId), tokenURI);
    }

    function test_tokenURI_AfterDeath() public mint unlock {
        assertEq(token.tokenURI(tokenId), tokenURI2);
    }

    function test_RevertWhen_tokenURI_ForNonexistentToken() public {
        vm.expectRevert(
            abi.encodeWithSelector(
                IERC721Errors.ERC721NonexistentToken.selector,
                tokenId
            )
        );
        token.tokenURI(tokenId);
    }
}
