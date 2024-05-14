// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.25;

import {AsideChainlink, Aside0x01TestHelper, FunctionsClient} from "./Aside0x01TestHelper.t.sol";

contract FulfillRequest is Aside0x01TestHelper {
    function test_fulfillRequest() public update {
        router.fulfillRequest(token, abi.encodePacked(sentiment), "");
        (uint256 lastSentiment, uint256 lastSentimentTimestamp) = token.lastSentiment();
        assertEq(lastSentiment, sentiment);
        assertEq(lastSentimentTimestamp, block.timestamp);
    }

    function test_RevertWhen_fulfillRequest_FromUnauthorized() public mint {
        bytes32 requestId = router.REQUEST_ID();
        vm.expectRevert(abi.encodeWithSelector(FunctionsClient.OnlyRouterCanFulfill.selector));
        token.handleOracleFulfillment(requestId, abi.encodePacked(sentiment), "");
    }

    function test_RevertWhen_fulfillRequest_WithInvalidRequestId() public mint {
        vm.expectRevert(abi.encodeWithSelector(AsideChainlink.InvalidRequestId.selector, router.REQUEST_ID()));
        router.fulfillRequest(token, abi.encodePacked(sentiment), "");
    }

    function test_RevertWhen_fulfillRequest_WithError() public mint update {
        vm.expectRevert(abi.encodeWithSelector(AsideChainlink.InvalidCallback.selector, "This is an error"));
        router.fulfillRequest(token, abi.encodePacked(sentiment), "This is an error");
    }
}
