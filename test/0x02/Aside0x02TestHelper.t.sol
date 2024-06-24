// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.25;

import {AsideBase, AsideBaseTestHelper, IAccessControl, IERC721Errors} from "../helpers/AsideBase/AsideBaseTestHelper.t.sol";
import {Aside0x02} from "../../src/Aside0x02.sol";

abstract contract Aside0x02TestHelper is AsideBaseTestHelper {
    Aside0x02 public token;

    function setUp() public {
        vm.warp(1_720_137_000);
        token = new Aside0x02(baseURI, admin, minter, verse, timelock);
        baseToken = AsideBase(token);
    }
}
