// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import {Aside0x01TestHelper, AsideChainlink, AsideBase, FunctionsClient} from "./Aside0x01TestHelper.t.sol";

contract FulfillRequest is Aside0x01TestHelper {
    function test_fulfillRequest() public update {
        router.fulfillRequest(token, abi.encodePacked(sentiment), "");
        (uint256 _sentiment, uint256 timestamp) = token.lastSentiment();
        assertEq(_sentiment, sentiment);
        assertEq(timestamp, block.timestamp);
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

    // function test_RevertWhen_fulfillRequest_WithInvalidSentiment() public mint {
    //     vm.prank(unlocker);
    //     token.unlock(_tokenIds());

    //     vm.expectRevert(abi.encodeWithSelector(AsideChainlink.InvalidUnlock.selector, tokenId, router.REQUEST_ID()));
    //     router.fulfillRequest(token, abi.encodePacked(sentiment - 1), "");

    //     vm.expectRevert(abi.encodeWithSelector(AsideChainlink.InvalidUnlock.selector, tokenId, router.REQUEST_ID()));
    //     router.fulfillRequest(token, abi.encodePacked(sentiment + 10), "");
    // }

    // function test_RevertWhen_fulfillRequest_ForAlreadyUnlockedToken() public mint {
    //     vm.prank(unlocker);
    //     token.unlock(_tokenIds());
    //     router.fulfillRequest(token, abi.encodePacked(sentiment), "");

    //     vm.expectRevert(abi.encodeWithSelector(AsideBase.TokenAlreadyUnlocked.selector, tokenId));
    //     router.fulfillRequest(token, abi.encodePacked(sentiment), "");
    // }
}
