// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {TestHelper, IAsideErrors, IERC721Errors, FunctionsRequest} from "./Aside0x01Helper.t.sol";

contract FulfillRequest is TestHelper {
    using FunctionsRequest for FunctionsRequest.Request;

    function test_FulfillRequest() public mint {
        FunctionsRequest.Request memory req;
        req.initializeRequestForInlineJavaScript(source);
        token.requestUnlock(tokenId);

        router.fulfillRequest(token, router.REQUEST_ID(), abi.encodePacked(sentiment), "");

        assertTrue(token.isUnlocked(tokenId));
    }

    function test_RevertWhen_FulfillRequestForNonexistentToken() public mint {
        token.requestUnlock(tokenId);
        _unlock();
        vm.prank(owner);
        token.burn(tokenId);

        vm.prank(address(router));
        vm.expectRevert(abi.encodeWithSelector(IERC721Errors.ERC721NonexistentToken.selector, tokenId));
        token.handleOracleFulfillment(requestId, abi.encodePacked(sentiment), "");
    }

    function test_RevertWhen_FulfillRequestForUnlockedToken() public mint {
        token.requestUnlock(tokenId);
        _unlock();

        vm.prank(address(router));
        vm.expectRevert(abi.encodeWithSelector(IAsideErrors.TokenUnlocked.selector, tokenId));
        token.handleOracleFulfillment(requestId, abi.encodePacked(sentiment), "");
    }

    function test_RevertWhen_FulfillRequestWithError() public mint {
        token.requestUnlock(tokenId);
        vm.prank(address(router));
        vm.expectRevert(abi.encodeWithSelector(IAsideErrors.RequestError.selector, "This is an error"));
        token.handleOracleFulfillment(requestId, abi.encodePacked(sentiment), "This is an error");
    }
}
