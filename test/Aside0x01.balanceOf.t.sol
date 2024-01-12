// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {TestHelper, IERC721Errors} from "./Aside0x01Helper.t.sol";

/**
 * Returns the number of tokens in `owner`'s account.
 */
contract BalanceOf is TestHelper {
    function test_BalanceOf() public mint {
        assertEq(token.balanceOf(owner), 1);
    }

    function test_RevertWhen_BalanceOfZeroAddress() public {
        vm.expectRevert(abi.encodeWithSelector(IERC721Errors.ERC721InvalidOwner.selector, address(0)));
        token.balanceOf(address(0));
    }
}
