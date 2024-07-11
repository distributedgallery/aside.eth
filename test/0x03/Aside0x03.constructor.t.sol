// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.25;

import {Aside0x03TestHelper} from "./Aside0x03TestHelper.t.sol";

contract Aside0x03Constructor is Aside0x03TestHelper {
    function test_constructor_FeedIsRegistered() public {
        assertEq(address(token.feed()), address(feed));
    }
}
