// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.25;

import {AsideChainlink, Aside0x05, Aside0x05TestHelper, FunctionsClient} from "./Aside0x05TestHelper.t.sol";

contract FulfillRequest is Aside0x05TestHelper {
    function test_fulfillRequest_WhenHarrisIsElected() public update {
        vm.expectEmit(address(token));
        emit Aside0x05.Unlock();
        router.fulfillRequest(token, abi.encodePacked(uint256(0)), "");
        assertEq(token.result(), 0);
    }

    function test_fulfillRequest_WhenTrumpIsElected() public update {
        vm.expectEmit(address(token));
        emit Aside0x05.Unlock();
        router.fulfillRequest(token, abi.encodePacked(uint256(1)), "");
        assertEq(token.result(), 1);
    }

    function test_fulfillRequest_WhenSomethingElseHappens() public update {
        vm.expectRevert(abi.encodeWithSelector(Aside0x05.InvalidElectionResult.selector, 3));
        router.fulfillRequest(token, abi.encodePacked(uint256(3)), "");
        assertEq(token.result(), 3);
    }

    function test_RevertWhen_fulfillRequest_FromUnauthorized() public {
        bytes32 requestId = router.REQUEST_ID();
        vm.expectRevert(abi.encodeWithSelector(FunctionsClient.OnlyRouterCanFulfill.selector));
        token.handleOracleFulfillment(requestId, abi.encodePacked(uint256(0)), "");
    }

    function test_RevertWhen_fulfillRequest_WithInvalidRequestId() public {
        vm.expectRevert(abi.encodeWithSelector(AsideChainlink.InvalidRequestId.selector, router.REQUEST_ID()));
        router.fulfillRequest(token, abi.encodePacked(uint256(0)), "");
    }

    function test_RevertWhen_fulfillRequest_WithError() public mint update {
        vm.expectRevert(abi.encodeWithSelector(AsideChainlink.InvalidCallback.selector, "This is an error"));
        router.fulfillRequest(token, abi.encodePacked(uint256(0)), "This is an error");
    }
}
