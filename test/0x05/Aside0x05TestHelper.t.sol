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
import {Aside0x05} from "../../src/Aside0x05.sol";

abstract contract Aside0x05TestHelper is AsideChainlinkTestHelper {
    Aside0x05 public token;

    modifier setUpUnlockConditions(uint256 result) {
        _setUpUnlockConditions(result);
        _;
    }

    function _setUpUnlockConditions(uint256 result) internal {
        _update();
        router.fulfillRequest(token, abi.encodePacked(result), "");
    }

    function setUp() public {
        router = new AsideChainlinkRouter();
        token = new Aside0x05(
            baseURI, admin, minter, updater, verse, timelock, address(router), donId, subscriptionId, callbackGasLimit, source
        );
        chainlinkToken = AsideChainlink(token);
        baseToken = AsideBase(token);
    }
}
