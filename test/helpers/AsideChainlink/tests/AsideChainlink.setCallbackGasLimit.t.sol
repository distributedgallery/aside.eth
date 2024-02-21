// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import {AsideChainlinkTestHelper, AsideChainlink, IAccessControl} from "../AsideChainlinkTestHelper.t.sol";

abstract contract SetCallbackGasLimit is AsideChainlinkTestHelper {
    function test_setCallbackGasLimit() public {
        vm.prank(admin);
        chainlinkToken.setCallbackGasLimit(callbackGasLimit + 1);
        assertEq(chainlinkToken.callbackGasLimit(), callbackGasLimit + 1);
    }

    function test_RevertWhen_setCallbackGasLimitFromUnauthorized() public {
        vm.expectRevert(
            abi.encodeWithSelector(
                IAccessControl.AccessControlUnauthorizedAccount.selector, address(this), chainlinkToken.DEFAULT_ADMIN_ROLE()
            )
        );
        chainlinkToken.setCallbackGasLimit(callbackGasLimit + 1);
    }

    function test_RevertWhen_setCallbackGasLimitToInvalidId() public {
        vm.prank(admin);
        vm.expectRevert(abi.encodeWithSelector(AsideChainlink.InvalidCallbackGasLimit.selector));
        chainlinkToken.setCallbackGasLimit(uint32(0));
    }
}
