// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import {
    AsideBase,
    AsideBaseTestHelper,
    AsideChainlink,
    AsideChainlinkTestHelper,
    AsideChainlinkRouter,
    FunctionsClient,
    IERC721Errors,
    IAccessControl
} from "../helpers/AsideChainlink/AsideChainlinkTestHelper.t.sol";
import {Aside0x01} from "../../src/Aside0x01.sol";

abstract contract Aside0x01TestHelper is AsideChainlinkTestHelper {
    Aside0x01 public token;
    uint256 public sentiment = 60;
    bytes public payload = abi.encodePacked(sentiment);

    function _mint() internal virtual override(AsideBaseTestHelper) {
        vm.prank(minter);
        token.mint(owner, tokenId, payload);
    }

    function _mint(address to) internal virtual override(AsideBaseTestHelper) {
        vm.prank(minter);
        token.mint(to, tokenId, payload);
    }

    function _setUpUnlockConditions() internal virtual override(AsideBaseTestHelper) {
        _update();
        router.fulfillRequest(token, abi.encodePacked(sentiment), "");
    }

    function setUp() public {
        router = new AsideChainlinkRouter();
        token = new Aside0x01(baseURI, admin, minter, updater, timelock, address(router), donId, subscriptionId, callbackGasLimit, source);
        chainlinkToken = AsideChainlink(token);
        baseToken = AsideBase(token);
    }
}
