// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.10;

import {ERC721GeneralSequence} from "hl-evm-contracts/erc721/ERC721GeneralSequence.sol";
import {ITokenManager} from "hl-evm-contracts/tokenManager/interfaces/ITokenManager.sol";
import {IPostTransfer} from "hl-evm-contracts/tokenManager/interfaces/IPostTransfer.sol";
import {Ownable} from "hl-evm-contracts//utils/Ownable.sol";
import {InterfaceSupportTokenManager} from "hl-evm-contracts/tokenManager/InterfaceSupportTokenManager.sol";

contract AsideTokenManager is ITokenManager, IPostTransfer, InterfaceSupportTokenManager, Ownable {
    mapping(uint256 => bool) _isUnlocked;

    constructor() Ownable() {}

    /**
     * @notice See {ITokenManager-canUpdateMetadata}
     */
    function canUpdateMetadata(address sender, uint256, /* id */ bytes calldata /* newTokenUri */ ) external view override returns (bool) {
        return Ownable(msg.sender).owner() == sender;
    }

    /**
     * @notice See {ITokenManager-canSwap}
     */
    function canSwap(address sender, uint256, /* id */ address /* newTokenManager */ ) external view override returns (bool) {
        return Ownable(msg.sender).owner() == sender;
    }

    /**
     * @notice See {ITokenManager-canRemoveItself}
     */
    function canRemoveItself(address sender, uint256 /* id */ ) external view override returns (bool) {
        return Ownable(msg.sender).owner() == sender;
    }

    /**
     * @notice See {IPostTransfer-postSafeTransferFrom}
     */
    function postSafeTransferFrom(address, /* operator */ address, /* from */ address, /* to */ uint256, /* id */ bytes memory /* data */ )
        external
        pure
        override
    {
        revert("Transfers disallowed");
    }

    /**
     * @notice See {IPostTransfer-postTransferFrom}
     */
    function postTransferFrom(address, /* operator */ address, /* from */ address, /* to */ uint256 /* id */ ) external pure override {
        revert("Transfers disallowed");
    }

    /**
     * @notice See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override(InterfaceSupportTokenManager) returns (bool) {
        return interfaceId == type(IPostTransfer).interfaceId || InterfaceSupportTokenManager.supportsInterface(interfaceId);
    }
}
