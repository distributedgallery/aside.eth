// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import {Aside0x01TestHelper, AsideBaseTestHelper, AsideChainlink} from "./Aside0x01TestHelper.t.sol";
import {AsideChainlinkTest} from "../helpers/AsideChainlink/tests/AsideChainlink.t.sol";

contract Aside0x01ChainlinkTest is Aside0x01TestHelper, AsideChainlinkTest {
    function _mint() internal override(Aside0x01TestHelper, AsideBaseTestHelper) {
        super._mint();
    }

    function test_tokenIdOf() public mint {
        token.requestUnlock(tokenId);
        assertEq(token.tokenIdOf(router.REQUEST_ID()), tokenId);
    }

    function test_RevertWhen_tokenIdOf_InvalidRequestId() public {
        bytes32 requestId = router.REQUEST_ID();
        vm.expectRevert(abi.encodeWithSelector(AsideChainlink.InvalidRequestId.selector, requestId));
        token.tokenIdOf(requestId);
    }

    function test_requestUnlock() public mint {
        token.requestUnlock(tokenId);
        assertEq(token.tokenIdOf(router.REQUEST_ID()), tokenId);
    }
}
