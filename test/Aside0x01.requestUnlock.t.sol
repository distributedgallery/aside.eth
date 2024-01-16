// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {TestHelper, Aside0x01, IERC721Errors, FunctionsRequest} from "./Aside0x01Helper.t.sol";

contract RequestUnlock is TestHelper {
    using FunctionsRequest for FunctionsRequest.Request;

    function test_RequestUnlock() public mint {
        FunctionsRequest.Request memory req;
        req.initializeRequestForInlineJavaScript(source);

        vm.expectEmit(true, true, true, true);
        emit RequestReceived(subscriptionId, req.encodeCBOR(), uint16(1), token.CALLBACK_GAS_LIMIT(), donId);

        token.requestUnlock(tokenId);
    }

    function test_RevertWhen_RequestUnlockOfNonexistentToken() public {
        FunctionsRequest.Request memory req;
        req.initializeRequestForInlineJavaScript(source);

        vm.expectRevert(abi.encodeWithSelector(IERC721Errors.ERC721NonexistentToken.selector, tokenId));
        token.requestUnlock(tokenId);
    }

    function test_RevertWhen_RequestUnlockOfUnlockedToken() public mint unlock {
        FunctionsRequest.Request memory req;
        req.initializeRequestForInlineJavaScript(source);

        vm.expectRevert(abi.encodeWithSelector(Aside0x01.TokenUnlocked.selector, tokenId));
        token.requestUnlock(tokenId);
    }
}
