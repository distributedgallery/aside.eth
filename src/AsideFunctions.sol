// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {FunctionsClient} from "chainlink/src/v0.8/functions/v1_0_0/FunctionsClient.sol";
import {FunctionsRequest} from "chainlink/src/v0.8/functions/v1_0_0/libraries/FunctionsRequest.sol";

/// @custom:security-contact contact@distributedgallery.art
abstract contract AsideFunctions is FunctionsClient {
    using FunctionsRequest for FunctionsRequest.Request;

    error InvalidRouter();
    error InvalidDonId();
    error InvalidSubscriptionId();

    address internal _router;
    bytes32 internal _donId;
    uint64 internal _subscriptionId;

    // bytes32 internal _currentRequestId;

    /**
     * @notice Creates a new AsideFunction contract.
     * @param router_ The address of the Chainlink Functions router.
     * @param donId_ The id of the Chainlink Functions DON.
     * @param subscriptionId_ The id of the Chainlink Functions subscription.
     */
    constructor(address router_, bytes32 donId_, uint64 subscriptionId_) FunctionsClient(router_) {
        _setRouter(router_);
        _setDonId(donId_);
        _setSubscriptionId(subscriptionId_);
    }

    /**
     * @notice Sets the Chainlink Functions router address.
     * @dev The implementation of this function should be protected by some access control mechanism.
     * @param router_ The address of the Chainlink Functions router.
     */
    function setRouter(address router_) external virtual;

    /**
     * @notice Sets the Chainlink Functions DON id.
     * @dev The implementation of this function should be protected by some access control mechanism.
     * @param donId_ The id of the Chainlink Functions DON.
     */
    function setDonId(bytes32 donId_) external virtual;

    /**
     * @notice Sets the Chainlink Functions subscription id.
     * @dev The implementation of this function should be protected by some access control mechanism.
     * @param subscriptionId_ The id of the Chainlink Functions subscription.
     */
    function setSubscriptionId(uint64 subscriptionId_) external virtual;

    /**
     * @notice Returns the Chainlink Functions router address.
     * @return The address of the Chainlink Functions router.
     */
    function router() public view returns (address) {
        return _router;
    }

    /**
     * @notice Returns the Chainlink Functions DON id.
     * @return The id of the Chainlink Functions DON.
     */
    function donId() public view returns (bytes32) {
        return _donId;
    }

    /**
     * @notice Returns the Chainlink Functions subscription id.
     * @return The id of the Chainlink Functions subscription.
     */
    function subscriptionId() public view returns (uint64) {
        return _subscriptionId;
    }

    function _setRouter(address router_) internal {
        if (router_ == address(0)) revert InvalidRouter();

        _router = router_;
    }

    function _setDonId(bytes32 donId_) internal {
        if (donId_ == bytes32(0)) revert InvalidDonId();

        _donId = donId_;
    }

    function _setSubscriptionId(uint64 subscriptionId_) internal {
        if (subscriptionId_ == 0) revert InvalidSubscriptionId();

        _subscriptionId = subscriptionId_;
    }
}
