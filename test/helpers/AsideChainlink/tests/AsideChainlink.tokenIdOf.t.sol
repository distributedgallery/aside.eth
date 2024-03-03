// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import {AsideChainlinkTestHelper, AsideChainlink} from "../AsideChainlinkTestHelper.t.sol";

abstract contract TokenIdOf is AsideChainlinkTestHelper {
    function test_tokenIdOf() public mint {
        vm.prank(unlocker);
        chainlinkToken.unlock(tokenId);
        assertEq(chainlinkToken.tokenIdOf(router.REQUEST_ID()), tokenId);
    }

    function test_RevertWhen_tokenIdOf_InvalidRequestId() public {
        bytes32 requestId = router.REQUEST_ID();
        vm.expectRevert(abi.encodeWithSelector(AsideChainlink.InvalidRequestId.selector, requestId));
        chainlinkToken.tokenIdOf(requestId);
    }
}
