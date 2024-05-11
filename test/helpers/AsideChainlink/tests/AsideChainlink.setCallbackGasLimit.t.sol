// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.25;

import {AsideChainlink, AsideChainlinkTestHelper, IAccessControl} from "../AsideChainlinkTestHelper.t.sol";

abstract contract SetCallbackGasLimit is AsideChainlinkTestHelper {
    function test_setCallbackGasLimit() public {
        vm.prank(admin);
        chainlinkToken.setCallbackGasLimit(callbackGasLimit + 1);
        assertEq(chainlinkToken.callbackGasLimit(), callbackGasLimit + 1);
    }

    function test_RevertWhen_setCallbackGasLimit_FromUnauthorized() public {
        vm.expectRevert(
            abi.encodeWithSelector(
                IAccessControl.AccessControlUnauthorizedAccount.selector, address(this), chainlinkToken.DEFAULT_ADMIN_ROLE()
            )
        );
        chainlinkToken.setCallbackGasLimit(callbackGasLimit + 1);
    }

    function test_RevertWhen_setCallbackGasLimit_ToInvalidCallbackGasLimit() public {
        vm.prank(admin);
        vm.expectRevert(abi.encodeWithSelector(AsideChainlink.InvalidCallbackGasLimit.selector));
        chainlinkToken.setCallbackGasLimit(uint32(0));
    }
}
