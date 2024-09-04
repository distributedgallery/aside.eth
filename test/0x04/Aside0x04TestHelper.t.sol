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
import {Aside0x04} from "../../src/Aside0x04.sol";

abstract contract Aside0x04TestHelper is AsideChainlinkTestHelper {
    Aside0x04 public token;
    uint256 public FOG_CODE = 741;

    modifier setUpUnlockConditions() {
        _setUpUnlockConditions();
        _;
    }

    function _setUpUnlockConditions() internal {
        _update();
        router.fulfillRequest(token, abi.encodePacked(FOG_CODE), "");
    }

    function setUp() public {
        router = new AsideChainlinkRouter();
        token = new Aside0x04(
            baseURI, admin, minter, updater, verse, timelock, address(router), donId, subscriptionId, callbackGasLimit, source
        );
        chainlinkToken = AsideChainlink(token);
        baseToken = AsideBase(token);
    }
}
