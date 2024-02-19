// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {TestHelper, IAccessControl} from "./Aside0x01Helper.t.sol";

/**
 * Reviewed: OK.
 */
contract SetSource is TestHelper {
    function test_setSource() public {
        vm.prank(admin);
        token.setSource("thisisadamnedsource");
        assertEq(token.source(), "thisisadamnedsource");
    }

    function test_RevertWhen_setSourceFromUnauthorized() public {
        vm.expectRevert(
            abi.encodeWithSelector(IAccessControl.AccessControlUnauthorizedAccount.selector, address(this), bytes32(0))
        );
        token.setSource("thisisadamnedsource");
    }
}
