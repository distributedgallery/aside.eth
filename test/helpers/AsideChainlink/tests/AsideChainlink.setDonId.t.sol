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
abstract contract AsideChainlinkSetDonId is AsideChainlinkTestHelper {
  function test_setDonId() public {
    vm.prank(admin);
    token.setDonId(bytes32(uint256(1)));
    assertEq(token.donId(), bytes32(uint256(1)));
  }

  function test_RevertWhen_setDonIdFromUnauthorized() public {
    vm.expectRevert(
      abi.encodeWithSelector(
        IAccessControl.AccessControlUnauthorizedAccount.selector, address(this), bytes32(0)
      )
    );
    token.setDonId(bytes32(uint256(1)));
  }

  function test_RevertWhen_setDonIdToInvalidId() public {
    vm.prank(admin);
    vm.expectRevert(abi.encodeWithSelector(AsideChainlink.InvalidDonId.selector));
    token.setDonId(bytes32(uint256(0)));
  }
}
