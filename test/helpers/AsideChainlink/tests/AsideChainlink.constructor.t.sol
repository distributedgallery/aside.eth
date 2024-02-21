// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import {AsideChainlinkTestHelper} from "../AsideChainlinkTestHelper.t.sol";

abstract contract Constructor is AsideChainlinkTestHelper {
    function test_constructor() public mint {
        assertEq(chainlinkToken.router(), address(router));
        assertEq(chainlinkToken.donId(), donId);
        assertEq(chainlinkToken.subscriptionId(), subscriptionId);
        assertEq(chainlinkToken.callbackGasLimit(), callbackGasLimit);
        assertEq(chainlinkToken.source(), source);
    }
}
