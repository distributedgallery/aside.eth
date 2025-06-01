// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.10;

import {ERC721GeneralSequence} from "hl-evm-contracts/erc721/ERC721GeneralSequence.sol";
import {ITokenManager} from "hl-evm-contracts/tokenManager/interfaces/ITokenManager.sol";
import {IPostTransfer} from "hl-evm-contracts/tokenManager/interfaces/IPostTransfer.sol";
import {InterfaceSupportTokenManager} from "hl-evm-contracts/tokenManager/InterfaceSupportTokenManager.sol";
import {Ownable} from "hl-evm-contracts/utils/Ownable.sol";

contract AsideTokenManager is
    ITokenManager,
    IPostTransfer,
    InterfaceSupportTokenManager,
    Ownable
{
    error TokenLocked();

    mapping(uint256 => bool) private _unlocked;
    uint256 public immutable UNLOCK_TIME;
    uint256 public constant UNLOCK_PERIOD = 12 * 365 days;

    constructor() Ownable() {
        UNLOCK_TIME = block.timestamp + UNLOCK_PERIOD;
    }

    /**
     * @notice Lock token `id`.
     * @param id The id of the token to lock.
     */
    function lock(uint256 id) external onlyOwner {
        _unlocked[id] = false;
    }

    /**
     * @notice Unlock token `id`.
     * @param id The id of the token to unlock.
     */
    function unlock(uint256 id) external onlyOwner {
        _unlocked[id] = true;
    }

    /**
     * @notice Returns whether token `id` is unlocked or not.
     * @param id The id of the tocken to check whether it is unlocked or not.
     */
    function isUnlocked(uint256 id) public view returns (bool) {
        return _isUnlocked(id);
    }

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
        if (!_isUnlocked(id)) revert TokenLocked();
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
        if (!_isUnlocked(id)) revert TokenLocked();
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

    function _isUnlocked(uint256 id) private view returns (bool) {
        if (block.timestamp >= UNLOCK_TIME) {
            return true;
        }
        return _unlocked[id];
    }
}
