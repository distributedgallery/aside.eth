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
    string public payload = "060";

    function _mint() internal virtual override(AsideBaseTestHelper) {
        vm.prank(minter);
        token.mint(owner, tokenId, payload);
    }

    function _mint(address to) internal virtual override(AsideBaseTestHelper) {
        vm.prank(minter);
        token.mint(to, tokenId, payload);
    }

    function setUp() public {
        router = new AsideChainlinkRouter();
        token = new Aside0x01(baseURI, admin, minter, unlocker, timelock, address(router), donId, subscriptionId, callbackGasLimit, source);
        chainlinkToken = AsideChainlink(token);
        baseToken = AsideBase(token);
    }
}
