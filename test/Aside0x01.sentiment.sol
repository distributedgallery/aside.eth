// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {TestHelper} from "./Aside0x01Helper.t.sol";

contract Sentiment is TestHelper {
    function test_Sentiment() public {
        token.fulfillRequest2(bytes32(uint256(10)), abi.encodePacked(uint256(50)), bytes(""));
    }
}
