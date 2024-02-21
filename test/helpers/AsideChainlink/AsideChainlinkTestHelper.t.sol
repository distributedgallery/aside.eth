// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import {AsideChainlinkRouter} from "./AsideChainlinkRouter.t.sol";
import {AsideBaseTestHelper, IAccessControl} from "../AsideBase/AsideBaseTestHelper.t.sol";
import {AsideChainlink} from "../../../src/AsideChainlink.sol";

abstract contract AsideChainlinkTestHelper is AsideBaseTestHelper {
    event RequestReceived(uint64 subscriptionId, bytes data, uint16 dataVersion, uint32 callbackGasLimit, bytes32 donId);

    AsideChainlink public chainlinkToken;
    AsideChainlinkRouter public router;
    bytes32 public requestId = bytes32(uint256(0x01));
    bytes32 public donId = 0x66756e2d657468657265756d2d7365706f6c69612d3100000000000000000000;
    uint64 public subscriptionId = 1;
    uint32 public callbackGasLimit = 100_000;
    string public source =
        "const response = await Functions.makeHttpRequest({url:'https://aside-js.vercel.app/api/aisentiment', method: 'GET'});if (response.error) {throw Error('Request failed');}return Functions.encodeUint256(response.data.sentiment.toFixed(2)*100);";
}
