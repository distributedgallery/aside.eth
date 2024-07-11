// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.25;

import {Aside0x03TestHelper, IAccessControl} from "./Aside0x03TestHelper.t.sol";

contract UpdateFeed is Aside0x03TestHelper {
    function test_updateFeed() public {
        address newFeed = address(0xDeadBeef);
        vm.prank(admin);
        token.updateFeed(newFeed);
        assertEq(address(token.feed()), newFeed);
    }

    function test_RevertWhen_updateFeed_FromUnauthorized() public {
        vm.expectRevert(
            abi.encodeWithSelector(IAccessControl.AccessControlUnauthorizedAccount.selector, address(this), token.DEFAULT_ADMIN_ROLE())
        );
        token.updateFeed(address(0xDead));
    }
}
