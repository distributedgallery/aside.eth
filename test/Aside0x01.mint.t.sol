// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {TestHelper, IAccessControl} from "./Aside0x01Helper.sol";

contract Mint is TestHelper {
    function test_Mint() public {
        vm.prank(minter);
        token.mint(owner, tokenId, timelock, tokenURI);

        assertEq(token.balanceOf(owner), 1);
        assertEq(token.ownerOf(tokenId), owner);
    }

    function test_RevertWhen_MintFromUnauthorized() public {
        vm.expectRevert(
            abi.encodeWithSelector(
                IAccessControl.AccessControlUnauthorizedAccount.selector, address(this), token.MINTER_ROLE()
            )
        );
        token.mint(owner, tokenId, timelock, tokenURI);
    }
}
