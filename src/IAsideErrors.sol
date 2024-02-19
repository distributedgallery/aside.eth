// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/// @custom:security-contact contact@distributedgallery.art
interface IAsideErrors {
    error TokenLocked(uint256 tokenId);
    error TokenUnlocked(uint256 tokenId);
    error TokenNotUnlocked(uint256 tokenId, bytes32 requestId, uint256 sentiment);
    error InvalidSubscriptionId();
    error InvalidSentiment(uint256 sentiment);
    error InvalidRequestId(bytes32 currentRequestId, bytes32 requestId);
    error RequestError(bytes err);
}
