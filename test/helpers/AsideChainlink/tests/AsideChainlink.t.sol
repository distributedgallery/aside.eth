// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.25;

import {Constructor} from "./AsideChainlink.constructor.t.sol";
import {SetCallbackGasLimit} from "./AsideChainlink.setCallbackGasLimit.t.sol";
import {SetDonId} from "./AsideChainlink.setDonId.t.sol";
import {SetSource} from "./AsideChainlink.setSource.t.sol";
import {SetSubscriptionId} from "./AsideChainlink.setSubscriptionId.t.sol";
import {Update} from "./AsideChainlink.update.t.sol";

abstract contract AsideChainlinkTest is Constructor, SetCallbackGasLimit, SetDonId, SetSource, SetSubscriptionId, Update {}
