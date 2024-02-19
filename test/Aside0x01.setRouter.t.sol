// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {TestHelper, AsideFunctions, IAccessControl} from "./Aside0x01Helper.t.sol";

/**
 * Reviewed: OK.
 */
contract SetRouter is TestHelper {
    function test_setRouter() public {
        vm.prank(admin);
        token.setRouter(address(this));
        assertEq(token.router(), address(this));
    }

    function test_RevertWhen_setRouterFromUnauthorized() public {
        vm.expectRevert(
            abi.encodeWithSelector(IAccessControl.AccessControlUnauthorizedAccount.selector, address(this), bytes32(0))
        );
        token.setRouter(address(this));
    }

    function test_RevertWhen_setRouterToInvalidAddress() public {
        vm.prank(admin);
        vm.expectRevert(abi.encodeWithSelector(AsideFunctions.InvalidRouter.selector));
        token.setRouter(address(0x0));
    }
}
