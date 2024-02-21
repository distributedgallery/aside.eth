// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import {Approve} from "./AsideBase.ERC721.approve.t.sol";
import {BalanceOf} from "./AsideBase.ERC721.balanceOf.t.sol";
import {OwnerOf} from "./AsideBase.ERC721.ownerOf.t.sol";
import {SafeTransferFrom} from "./AsideBase.ERC721.safeTransferFrom.t.sol";

abstract contract AsideBaseERC721Test is Approve, BalanceOf, OwnerOf, SafeTransferFrom {}
