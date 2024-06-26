// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.25;

import {AsideChainlink, AsideChainlinkTestHelper, IAccessControl} from "../AsideChainlinkTestHelper.t.sol";

abstract contract SetDonId is AsideChainlinkTestHelper {
    function test_setDonId() public {
        vm.prank(admin);
        chainlinkToken.setDonId(bytes32(uint256(1)));
        assertEq(chainlinkToken.donId(), bytes32(uint256(1)));
    }

    function test_RevertWhen_setDonId_FromUnauthorized() public {
        vm.expectRevert(
            abi.encodeWithSelector(
                IAccessControl.AccessControlUnauthorizedAccount.selector, address(this), chainlinkToken.DEFAULT_ADMIN_ROLE()
            )
        );
        chainlinkToken.setDonId(bytes32(uint256(1)));
    }

    function test_RevertWhen_setDonId_ToInvalidDonId() public {
        vm.prank(admin);
        vm.expectRevert(abi.encodeWithSelector(AsideChainlink.InvalidDonId.selector));
        chainlinkToken.setDonId(bytes32(uint256(0)));
    }
}
