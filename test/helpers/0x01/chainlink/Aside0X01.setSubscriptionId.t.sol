// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Aside0x01TestHelper} from "../Aside0x01TestHelper.t.sol";
import {AsideChainlinkSetSubscriptionId} from
  "../../AsideChainlink/tests/AsideChainlink.setSubscriptionId.t.sol";

contract SetSubscriptionId is Aside0x01TestHelper, AsideChainlinkSetSubscriptionId {}
