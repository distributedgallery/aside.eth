// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.25;

import {Aside0x01TestHelper} from "./Aside0x01TestHelper.t.sol";

contract LastSentiment is Aside0x01TestHelper {
    function test_lastSentiment() public mint setUpUnlockConditions {
        (uint256 lastSentiment, uint256 lastSentimentTimestamp) = token.lastSentiment();
        assertEq(lastSentiment, sentiment);
        assertEq(lastSentimentTimestamp, block.timestamp);
    }
}
