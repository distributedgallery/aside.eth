// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.25;

import {
    AsideChainlink,
    AsideBase,
    AsideChainlinkTestHelper,
    AsideBaseTestHelper,
    AsideChainlinkRouter,
    FunctionsClient,
    IAccessControl,
    IERC721Errors
} from "../helpers/AsideChainlink/AsideChainlinkTestHelper.t.sol";
import {Aside0x01} from "../../src/Aside0x01.sol";

abstract contract Aside0x01TestHelper is AsideChainlinkTestHelper {
    Aside0x01 public token;
    uint256 public sentiment = 10;

    modifier setUpUnlockConditions() {
        _setUpUnlockConditions();
        _;
    }

    function _setUpUnlockConditions() internal {
        _update();
        router.fulfillRequest(token, abi.encodePacked(sentiment), "");
    }

    function setUp() public {
        router = new AsideChainlinkRouter();
        token = new Aside0x01(
            baseURI, admin, minter, updater, verse, timelock, address(router), donId, subscriptionId, callbackGasLimit, source
        );
        chainlinkToken = AsideChainlink(token);
        baseToken = AsideBase(token);
    }
}
