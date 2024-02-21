// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import {AreAllUnlocked} from "./AsideBase.areAllUnlocked.t.sol";
import {Constructor} from "./AsideBase.constructor.t.sol";
import {ERelock} from "./AsideBase.eRelock.t.sol";
import {EUnlock} from "./AsideBase.eUnlock.t.sol";
import {IsUnlocked} from "./AsideBase.isUnlocked.t.sol";

abstract contract AsideBaseTest is AreAllUnlocked, Constructor, ERelock, EUnlock, IsUnlocked {}
