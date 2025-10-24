// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.25;

import {Aside0x08TestHelper, IERC721Errors} from "../Aside0x08TestHelper.t.sol";

abstract contract BalanceOf is Aside0x08TestHelper {
    function test_balanceOf() public mint {
        assertEq(token.balanceOf(owner), 1);
        assertEq(token.balanceOf(recipient), 0);
    }

    function test_RevertWhen_balanceOf_ForZeroAddress() public {
        vm.expectRevert(
            abi.encodeWithSelector(
                IERC721Errors.ERC721InvalidOwner.selector,
                address(0)
            )
        );
        token.balanceOf(address(0));
    }
}
