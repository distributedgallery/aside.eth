// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import {AsideChainlinkTestHelper, AsideChainlink} from "../AsideChainlinkTestHelper.t.sol";

abstract contract TokenIdOf is AsideChainlinkTestHelper {
    function test_tokenIdOf() public mint {
        vm.prank(unlocker);
        chainlinkToken.unlock(_tokenIds());
        uint256[] memory tokenIds = chainlinkToken.tokenIdsOf(router.REQUEST_ID());
        assertEq(tokenIds.length, 1);
        assertEq(tokenIds[0], tokenId);
    }

    function test_RevertWhen_tokenIdOf_InvalidRequestId() public {
        bytes32 requestId = router.REQUEST_ID();
        vm.expectRevert(abi.encodeWithSelector(AsideChainlink.InvalidRequestId.selector, requestId));
        chainlinkToken.tokenIdsOf(requestId);
    }
}
