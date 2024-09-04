// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.25;

import {AsideChainlink, Aside0x04, Aside0x04TestHelper, FunctionsClient} from "./Aside0x04TestHelper.t.sol";

contract FulfillRequest is Aside0x04TestHelper {
    function _testUnlocked() private {
        assertTrue(token.areAllUnlocked());
        for (uint256 i = 30; i <= 35; i++) {
            assertTrue(token.isUnlocked(i));
        }
    }

    function test_fulfillRequest_WithRightWeatherCode() public update {
        assertFalse(token.areAllUnlocked());
        vm.expectEmit(address(token));
        emit Aside0x04.Unlock();
        router.fulfillRequest(token, abi.encodePacked(FOG_CODE), "");
        _testUnlocked();
    }

    function test_fulfillRequest_WithWrongWeatherCode() public update {
        vm.expectRevert(abi.encodeWithSelector(Aside0x04.InvalidWeatherCode.selector, FOG_CODE + 1));
        router.fulfillRequest(token, abi.encodePacked(FOG_CODE + 1), "");
        assertFalse(token.areAllUnlocked());
    }

    function test_RevertWhen_fulfillRequest_FromUnauthorized() public {
        bytes32 requestId = router.REQUEST_ID();
        vm.expectRevert(abi.encodeWithSelector(FunctionsClient.OnlyRouterCanFulfill.selector));
        token.handleOracleFulfillment(requestId, abi.encodePacked(FOG_CODE), "");
    }

    function test_RevertWhen_fulfillRequest_WithInvalidRequestId() public {
        vm.expectRevert(abi.encodeWithSelector(AsideChainlink.InvalidRequestId.selector, router.REQUEST_ID()));
        router.fulfillRequest(token, abi.encodePacked(FOG_CODE), "");
    }

    function test_RevertWhen_fulfillRequest_WithError() public mint update {
        vm.expectRevert(abi.encodeWithSelector(AsideChainlink.InvalidCallback.selector, "This is an error"));
        router.fulfillRequest(token, abi.encodePacked(FOG_CODE), "This is an error");
    }
}
