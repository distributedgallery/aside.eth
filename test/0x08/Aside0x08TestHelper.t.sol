// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.25;

import {AsideBase, AsideBaseTestHelper, IAccessControl, IERC721Errors} from "../helpers/AsideBase/AsideBaseTestHelper.t.sol";
import {Aside0x08} from "../../src/Aside0x08.sol";

abstract contract Aside0x08TestHelper is AsideBaseTestHelper {
    Aside0x08 public token;
    string public constant baseURI2 =
        "ipfs://bafybeicy53j7e2er5kmft4rzj7ijr2cljgxxitnmmqztrdfst4i5z4pa74/2/";

    function setUp() public {
        token = new Aside0x08(
            baseURI,
            baseURI2,
            admin,
            minter,
            verse,
            timelock
        );
        baseToken = AsideBase(token);
    }
}
