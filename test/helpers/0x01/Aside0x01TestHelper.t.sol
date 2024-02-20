// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Aside0x01} from "../../../src/Aside0x01.sol";
import {
  AsideChainlinkTestHelper,
  AsideChainlink,
  AsideChainlinkRouter,
  IAccessControl
} from "../AsideChainlink/AsideChainlinkTestHelper.t.sol";
import {FunctionsRequest} from
  "../../../lib/chainlink/contracts/src/v0.8/functions/v1_0_0/libraries/FunctionsRequest.sol";

contract Aside0x01TestHelper is AsideChainlinkTestHelper {
  uint256 public sentiment = 60;

  // function token() public override(AsideChainlinkTestHelper) returns (AsideChainlink) {
  //     return _token;
  // }

  modifier mint() {
    vm.prank(minter);
    Aside0x01(address(token)).mint(owner, tokenId, sentiment, tokenURI);
    _;
  }

  modifier unlock() {
    _unlock();
    _;
  }

  function setUp() public {
    router = new AsideChainlinkRouter();
    token = new Aside0x01(admin, minter, timelock, address(router), donId, subscriptionId);
  }

  function _unlock() internal {
    vm.warp(token.TIMELOCK_DEADLINE());
  }
}
