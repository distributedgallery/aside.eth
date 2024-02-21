// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import {AsideBaseTestHelper, IERC721Errors} from "../../AsideBaseTestHelper.t.sol";

abstract contract BalanceOf is AsideBaseTestHelper {
    function test_balanceOf() public mint {
        assertEq(baseToken.balanceOf(owner), 1);
        assertEq(baseToken.balanceOf(recipient), 0);
    }

    function test_RevertWhen_balanceOf_ForZeroAddress() public {
        vm.expectRevert(abi.encodeWithSelector(IERC721Errors.ERC721InvalidOwner.selector, address(0)));
        baseToken.balanceOf(address(0));
    }
}
