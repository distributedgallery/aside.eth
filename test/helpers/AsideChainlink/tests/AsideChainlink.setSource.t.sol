// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.25;

import {AsideChainlink, AsideChainlinkTestHelper, IAccessControl} from "../AsideChainlinkTestHelper.t.sol";

abstract contract SetSource is AsideChainlinkTestHelper {
    function test_setSource() public {
        vm.prank(admin);
        chainlinkToken.setSource("thisisadamnedsource");
        assertEq(chainlinkToken.source(), "thisisadamnedsource");
    }

    function test_RevertWhen_setSource_FromUnauthorized() public {
        vm.expectRevert(
            abi.encodeWithSelector(
                IAccessControl.AccessControlUnauthorizedAccount.selector, address(this), chainlinkToken.DEFAULT_ADMIN_ROLE()
            )
        );
        chainlinkToken.setSource("thisisadamnedsource");
    }

    function test_RevertWhen_setSource_ToInvalidSource() public {
        vm.prank(admin);
        vm.expectRevert(abi.encodeWithSelector(AsideChainlink.InvalidSource.selector));
        chainlinkToken.setSource("");
    }
}
