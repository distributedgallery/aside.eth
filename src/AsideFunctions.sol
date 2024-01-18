// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {FunctionsClient} from "chainlink/src/v0.8/functions/v1_0_0/FunctionsClient.sol";
import {FunctionsRequest} from "chainlink/src/v0.8/functions/v1_0_0/libraries/FunctionsRequest.sol";

/// @custom:security-contact contact@distributedgallery.art
abstract contract AsideFunctions is FunctionsClient {
    using FunctionsRequest for FunctionsRequest.Request;

    error UnexpectedRequestID(bytes32 requestId);
    error InvalidRouter(address router);
    error InvalidDonId(bytes32 donId);

    address internal _router;
    bytes32 internal _donId;
    bytes32 internal _currentRequestId;

    /**
     * @notice Creates a new AsideFunction contract.
     * @param router_ The address of the Chainlink Functions router.
     * @param donId_ The id of the Chainlink Functions DON.
     */
    constructor(address router_, bytes32 donId_) FunctionsClient(router_) {
        if (router_ == address(0)) revert InvalidRouter(router_);
        if (donId_ == bytes32(0)) revert InvalidDonId(donId_);

        _setRouter(router_);
        _setDonId(donId_);
    }

    /**
     * @notice Sets the Chainlink Functions router address.
     * @dev The implementation of this function should be protected by some access control mechanism.
     * @param router_ The address of the Chainlink Functions router.
     */
    function setRouter(address router_) external virtual;

    /**
     * @notice Sets the Chainlink Functions DON identifier.
     * @dev The implementation of this function should be protected by some access control mechanism.
     * @param donId_ The identifier of the Chainlink Functions DON.
     */
    function setDonId(bytes32 donId_) external virtual;

    function router() public view returns (address) {
        return _router;
    }

    function donId() public view returns (bytes32) {
        return _donId;
    }

    function _setRouter(address router_) internal {
        _router = router_;
    }

    function _setDonId(bytes32 donId_) internal {
        _donId = donId_;
    }
}
