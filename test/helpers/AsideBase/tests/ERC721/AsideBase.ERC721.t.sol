// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.25;

import {Approve} from "./AsideBase.ERC721.approve.t.sol";
import {BalanceOf} from "./AsideBase.ERC721.balanceOf.t.sol";
import {Burn} from "./AsideBase.ERC721.burn.t.sol";
import {Mint} from "./AsideBase.ERC721.mint.t.sol";
import {OwnerOf} from "./AsideBase.ERC721.ownerOf.t.sol";
import {SafeTransferFrom} from "./AsideBase.ERC721.safeTransferFrom.t.sol";
import {SetApprovalForAll} from "./AsideBase.ERC721.setApprovalForAll.t.sol";
import {TokenURI} from "./AsideBase.ERC721.tokenURI.t.sol";
import {TransferFrom} from "./AsideBase.ERC721.transferFrom.t.sol";

abstract contract AsideBaseERC721Test is
    Approve,
    BalanceOf,
    Burn,
    Mint,
    OwnerOf,
    SafeTransferFrom,
    SetApprovalForAll,
    TokenURI,
    TransferFrom
{}
