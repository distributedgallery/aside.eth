// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import {Aside0x01} from "../../../src/Aside0x01.sol";
import {AsideBase} from "../AsideBase/AsideBaseTestHelper.t.sol";
import {
    AsideBaseTestHelper,
    AsideChainlinkTestHelper,
    AsideChainlink,
    AsideChainlinkRouter,
    IAccessControl
} from "../AsideChainlink/AsideChainlinkTestHelper.t.sol";
import {FunctionsRequest} from "../../../lib/chainlink/contracts/src/v0.8/functions/v1_0_0/libraries/FunctionsRequest.sol";

abstract contract Aside0x01TestHelper is AsideBaseTestHelper, AsideChainlinkTestHelper {
    uint256 public sentiment = 60;
    Aside0x01 public token;

    // function token() public override(AsideChainlinkTestHelper) returns (AsideChainlink) {
    //     return _token;
    // }

    function _mint() internal virtual override(AsideBaseTestHelper) {
        vm.prank(minter);
        Aside0x01(address(token)).mint(owner, tokenId, sentiment, tokenURI);
    }

    // modifier mint() virtual override(AsideChainlinkTestHelper) {
    //     _;
    // }

    function setUp() public {
        router = new AsideChainlinkRouter();
        token = new Aside0x01(admin, minter, address(router), donId, subscriptionId, callbackGasLimit, source);
        baseToken = AsideBase(token);
        chainlinkToken = AsideChainlink(token);
    }
}
