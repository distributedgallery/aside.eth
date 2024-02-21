// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/// @custom:security-contact contact@distributedgallery.art
interface IAsideErrors {
    error TokenNotUnlocked(uint256 tokenId, bytes32 requestId, uint256 sentiment);
    error InvalidSentiment(uint256 sentiment);
    error RequestError(bytes err);
}
