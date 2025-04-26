// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.10;

import {ERC721GeneralSequence} from "hl-evm-contracts/erc721/ERC721GeneralSequence.sol";
import {ITokenManager} from "hl-evm-contracts/tokenManager/interfaces/ITokenManager.sol";
import {IPostTransfer} from "hl-evm-contracts/tokenManager/interfaces/IPostTransfer.sol";
import {Ownable} from "hl-evm-contracts//utils/Ownable.sol";
import {InterfaceSupportTokenManager} from "hl-evm-contracts/tokenManager/InterfaceSupportTokenManager.sol";

contract AsideTokenManager is
    ITokenManager,
    IPostTransfer,
    InterfaceSupportTokenManager,
    Ownable
{
    error TokenLocked();

    mapping(uint256 => bool) private _isUnlocked;

    constructor() Ownable() {}

    /**
     * @notice See {ITokenManager-canUpdateMetadata}
     */
    function canUpdateMetadata(
        address sender,
        uint256,
        /* id */ bytes calldata /* newTokenUri */
    ) external view override returns (bool) {
        return Ownable(msg.sender).owner() == sender;
    }

    /**
     * @notice See {ITokenManager-canSwap}
     */
    function canSwap(
        address sender,
        uint256,
        /* id */ address /* newTokenManager */
    ) external view override returns (bool) {
        return Ownable(msg.sender).owner() == sender;
    }

    /**
     * @notice See {ITokenManager-canRemoveItself}
     */
    function canRemoveItself(
        address sender,
        uint256 /* id */
    ) external view override returns (bool) {
        return Ownable(msg.sender).owner() == sender;
    }

    /**
     * @notice See {IPostTransfer-postSafeTransferFrom}
     */
    function postSafeTransferFrom(
        address,
        /* operator */ address,
        /* from */ address,
        /* to */ uint256 id,
        bytes memory /* data */
    ) external view override {
        if (!_isUnlocked[id]) revert TokenLocked();
    }

    /**
     * @notice See {IPostTransfer-postTransferFrom}
     */
    function postTransferFrom(
        address,
        /* operator */ address,
        /* from */ address,
        /* to */ uint256 id
    ) external view override {
        if (!_isUnlocked[id]) revert TokenLocked();
    }

    function lock(uint256 tokenId) external onlyOwner {
        _isUnlocked[tokenId] = false;
    }

    function unlock(uint256 tokenId) external onlyOwner {
        _isUnlocked[tokenId] = true;
    }

    function isUnlocked(uint256 tokenId) public view returns (bool) {
        return _isUnlocked[tokenId];
    }

    /**
     * @notice See {IERC165-supportsInterface}.
     */
    function supportsInterface(
        bytes4 interfaceId
    )
        public
        view
        virtual
        override(InterfaceSupportTokenManager)
        returns (bool)
    {
        return
            interfaceId == type(IPostTransfer).interfaceId ||
            InterfaceSupportTokenManager.supportsInterface(interfaceId);
    }
}
