// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {AsideBase} from "./AsideBase.sol";
import {FunctionsClient} from "chainlink/src/v0.8/functions/v1_0_0/FunctionsClient.sol";
import {FunctionsRequest} from "chainlink/src/v0.8/functions/v1_0_0/libraries/FunctionsRequest.sol";

abstract contract AsideChainlink is AsideBase, FunctionsClient {
    error InvalidDonId();
    error InvalidSubscriptionId();
    error InvalidCallbackGasLimit();
    error InvalidSource();
    error InvalidUnlockRequest(uint256 tokenId, bytes32 requestId);
    error InvalidChainlinkRequest(bytes err);

    address internal _router;
    bytes32 internal _donId;
    uint64 internal _subscriptionId;
    uint32 internal _callbackGasLimit;
    string internal _source;

    mapping(bytes32 => uint256) internal _tokenIds; // requestId => tokenId

    /**
     * @notice Creates a new AsideChainlink contract.
     * @param name_ The name of the token.
     * @param symbol_ The symbol of the token.
     * @param admin_ The address to set as the DEFAULT_ADMIN of this contract.
     * @param minter_ The address to set as the MINTER of this contract.
     * @param timelock_ The duration of the timelock upon which all tokens are automatically unlocked.
     * @param router_ The address of the Chainlink Functions router.
     * @param donId_ The id of the Chainlink Functions DON.
     * @param subscriptionId_ The id of the Chainlink Functions subscription.
     * @param callbackGasLimit_ The callback gas limit of the Chainlink Functions call.
     * @param source_ The source of the Chainlink Functions call.
     */
    constructor(
        string memory name_,
        string memory symbol_,
        address admin_,
        address minter_,
        uint256 timelock_,
        address router_,
        bytes32 donId_,
        uint64 subscriptionId_,
        uint32 callbackGasLimit_,
        string memory source_
    ) AsideBase(name_, symbol_, admin_, minter_, timelock_) FunctionsClient(router_) {
        _setDonId(donId_);
        _setSubscriptionId(subscriptionId_);
        _setCallbackGasLimit(callbackGasLimit_);
        _setSource(source_);
    }

    // #region admin-only functions
    /**
     * @notice Sets the Chainlink Functions DON id.
     * @param donId_ The id of the Chainlink Functions DON.
     */
    function setDonId(bytes32 donId_) external onlyRole(DEFAULT_ADMIN_ROLE) {
        _setDonId(donId_);
    }

    /**
     * @notice Sets the Chainlink Functions subscription id.
     * @param subscriptionId_ The id of the Chainlink Functions subscription.
     */
    function setSubscriptionId(uint64 subscriptionId_) external onlyRole(DEFAULT_ADMIN_ROLE) {
        _setSubscriptionId(subscriptionId_);
    }

    /**
     * @notice Sets the callback gas limit of the Chainlink Functions call.
     * @param callbackGasLimit_ The callback gas limit of the Chainlink Functions call.
     */
    function setCallbackGasLimit(uint32 callbackGasLimit_) external onlyRole(DEFAULT_ADMIN_ROLE) {
        _setCallbackGasLimit(callbackGasLimit_);
    }

    /**
     * @notice Sets the source of the Chainlink Functions call.
     * @param source_ The source of the Chainlink Functions call.
     */
    function setSource(string memory source_) external onlyRole(DEFAULT_ADMIN_ROLE) {
        _setSource(source_);
    }
    // #endregion

    // #region getters
    /**
     * @notice Returns the Chainlink Functions router address.
     * @return The address of the Chainlink Functions router.
     */
    function router() public view returns (address) {
        return address(i_router);
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

    /**
     * @notice Returns the callback gas limit of the Chainlink Functions call.
     * @return The callback gas limit of the Chainlink Functions call.
     */
    function callbackGasLimit() public view returns (uint32) {
        return _callbackGasLimit;
    }

    /**
     * @notice Returns the source of the Chainlink Functions call.
     * @return The source of the Chainlink Functions call.
     */
    function source() public view returns (string memory) {
        return _source;
    }

    /**
     * @notice Returns the tokenId associated to the request `requestId`.
     * @param requestId The id of the request to get the tokenId associated to.
     * @return The tokenId associated to the request `requestId`.
     */
    function tokenIdOf(bytes32 requestId) public view returns (uint256) {
        return _tokenIds[requestId];
    }
    // #endregion

    // #region internal functions
    function _setDonId(bytes32 donId_) internal {
        if (donId_ == bytes32(0)) revert InvalidDonId();

        _donId = donId_;
    }

    function _setSubscriptionId(uint64 subscriptionId_) internal {
        if (subscriptionId_ == uint64(0)) revert InvalidSubscriptionId();

        _subscriptionId = subscriptionId_;
    }

    function _setCallbackGasLimit(uint32 callbackGasLimit_) internal {
        if (callbackGasLimit_ == uint32(0)) revert InvalidCallbackGasLimit();

        _callbackGasLimit = callbackGasLimit_;
    }

    function _setSource(string memory source_) internal {
        if (bytes(source_).length == 0) revert InvalidSource();

        _source = source_;
    }
    // #endregion
}
