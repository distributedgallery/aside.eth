// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.25;

import {AreAllUnlocked} from "./AsideBase.areAllUnlocked.t.sol";
import {Constructor} from "./AsideBase.constructor.t.sol";
import {EUnlock} from "./AsideBase.eUnlock.t.sol";
import {IsUnlocked} from "./AsideBase.isUnlocked.t.sol";
import {Unlock} from "./AsideBase.unlock.t.sol";

abstract contract AsideBaseTest is AreAllUnlocked, Constructor, EUnlock, IsUnlocked, Unlock {}
