// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.25;

import {AsideBase, AsideBaseTestHelper, IAccessControl, IERC721Errors} from "../helpers/AsideBase/AsideBaseTestHelper.t.sol";
import {PriceFeed} from "./helpers/PriceFeed.t.sol";
import {Aside0x03} from "../../src/Aside0x03.sol";

abstract contract Aside0x03TestHelper is AsideBaseTestHelper {
    event Unlock();

    Aside0x03 public token;
    PriceFeed public feed;

    function setUp() public {
        feed = new PriceFeed();
        token = new Aside0x03(baseURI, admin, minter, verse, timelock, address(feed));
        baseToken = AsideBase(token);
    }
}
