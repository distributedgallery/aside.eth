// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import {AsideChainlinkTestHelper, AsideChainlink, IAccessControl} from "../AsideChainlinkTestHelper.t.sol";

abstract contract SetSubscriptionId is AsideChainlinkTestHelper {
    function test_setSubscriptionId() public {
        vm.prank(admin);
        chainlinkToken.setSubscriptionId(subscriptionId + 1);
        assertEq(chainlinkToken.subscriptionId(), subscriptionId + 1);
    }

    function test_RevertWhen_setSubscriptionIdFromUnauthorized() public {
        vm.expectRevert(
            abi.encodeWithSelector(
                IAccessControl.AccessControlUnauthorizedAccount.selector, address(this), chainlinkToken.DEFAULT_ADMIN_ROLE()
            )
        );
        chainlinkToken.setSubscriptionId(subscriptionId + 1);
    }

    function test_RevertWhen_setSubscriptionIdToInvalidId() public {
        vm.prank(admin);
        vm.expectRevert(abi.encodeWithSelector(AsideChainlink.InvalidSubscriptionId.selector));
        chainlinkToken.setSubscriptionId(uint64(0));
    }
}
