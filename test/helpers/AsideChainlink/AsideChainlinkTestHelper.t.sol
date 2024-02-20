// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {AsideChainlinkRouter} from "./AsideChainlinkRouter.t.sol";
import {AsideTestHelper, IAccessControl} from "../Aside/AsideTestHelper.t.sol";
import {AsideChainlink} from "../../../src/AsideChainlink.sol";
import {FunctionsRequest} from
  "../../../lib/chainlink/contracts/src/v0.8/functions/v1_0_0/libraries/FunctionsRequest.sol";

abstract contract AsideChainlinkTestHelper is AsideTestHelper {
  event RequestReceived(
    uint64 subscriptionId, bytes data, uint16 dataVersion, uint32 callbackGasLimit, bytes32 donId
  );

  AsideChainlink public token;
  AsideChainlinkRouter public router;
  bytes32 public requestId = bytes32(uint256(0x01));
  bytes32 public donId = 0x66756e2d657468657265756d2d7365706f6c69612d3100000000000000000000;
  uint64 public subscriptionId = 1;
  string public source = "chainlink";
}
