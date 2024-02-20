// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {
  AsideChainlinkTestHelper,
  AsideChainlink,
  IAccessControl
} from "../AsideChainlinkTestHelper.t.sol";

/**
 * Reviewed: OK.
 */
abstract contract AsideChainlinkSetSubscriptionId is AsideChainlinkTestHelper {
  function test_setSubscriptionId() public {
    vm.prank(admin);
    token.setSubscriptionId(uint64(9999));
    assertEq(token.subscriptionId(), uint64(9999));
  }

  function test_RevertWhen_setSubscriptionIdFromUnauthorized() public {
    vm.expectRevert(
      abi.encodeWithSelector(
        IAccessControl.AccessControlUnauthorizedAccount.selector, address(this), bytes32(0)
      )
    );
    token.setSubscriptionId(uint64(9999));
  }

  function test_RevertWhen_setSubscriptionIdToInvalidId() public {
    vm.prank(admin);
    vm.expectRevert(abi.encodeWithSelector(AsideChainlink.InvalidSubscriptionId.selector));
    token.setSubscriptionId(uint64(0));
  }
}
