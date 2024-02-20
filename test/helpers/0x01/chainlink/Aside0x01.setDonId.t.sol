// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Aside0x01TestHelper} from "../Aside0x01TestHelper.t.sol";
import {AsideChainlinkSetDonId} from "../../AsideChainlink/tests/AsideChainlink.setDonId.t.sol";
import {AsideChainlinkSetSubscriptionId} from
  "../../AsideChainlink/tests/AsideChainlink.setSubscriptionId.t.sol";

contract SetDonId is Aside0x01TestHelper, AsideChainlinkSetDonId, AsideChainlinkSetSubscriptionId {}
