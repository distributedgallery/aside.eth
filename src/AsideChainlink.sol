// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

import {AsideBase} from "./AsideBase.sol";
import {FunctionsClient} from "chainlink/src/v0.8/functions/v1_0_0/FunctionsClient.sol";
import {FunctionsRequest} from "chainlink/src/v0.8/functions/v1_0_0/libraries/FunctionsRequest.sol";

abstract contract AsideChainlink is AsideBase, FunctionsClient {
    using FunctionsRequest for FunctionsRequest.Request;

    error InvalidDonId();
    error InvalidSubscriptionId();
    error InvalidCallbackGasLimit();
    error InvalidSource();
    error InvalidRequestId(bytes32 requestId);
    error InvalidCallback(bytes err);
    error DeprecatedData();

    modifier onlyValidRequestId(bytes32 requestId) {
        if (requestId != _lastRequestId) revert InvalidRequestId(requestId);
        _;
    }

    modifier onlyValidCallback(bytes memory err) {
        if (err.length != 0) revert InvalidCallback(err);
        _;
    }

    bytes32 public constant UPDATER_ROLE = keccak256("UPDATER_ROLE");
    bytes32 private _donId;
    uint64 private _subscriptionId;
    uint32 private _callbackGasLimit;
    string private _source;
    bytes32 private _lastRequestId;

    /**
     * @notice Creates a new AsideChainlink contract.
     * @param name_ The name of the token.
     * @param symbol_ The symbol of the token.
     * @param baseURI_ The base URI of the token.
     * @param admin_ The address to set as the DEFAULT_ADMIN of this contract.
     * @param minter_ The address to set as the MINTER of this contract.
     * @param updater_ The address to set as the UPDATER of this contract.
     * @param verse_ The address of Verse's custodial wallet.
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
        string memory baseURI_,
        address admin_,
        address minter_,
        address updater_,
        address verse_,
        uint256 timelock_,
        address router_,
        bytes32 donId_,
        uint64 subscriptionId_,
        uint32 callbackGasLimit_,
        string memory source_
    ) AsideBase(name_, symbol_, baseURI_, admin_, minter_, verse_, timelock_) FunctionsClient(router_) {
        _grantRole(UPDATER_ROLE, updater_);
        _setDonId(donId_);
        _setSubscriptionId(subscriptionId_);
        _setCallbackGasLimit(callbackGasLimit_);
        _setSource(source_);
    }

    function update(string[] calldata args) external onlyRole(UPDATER_ROLE) {
        FunctionsRequest.Request memory request;
        request.initializeRequestForInlineJavaScript(_source);
        if (args.length > 0) request.setArgs(args);
        bytes32 requestId = _sendRequest(request.encodeCBOR(), _subscriptionId, _callbackGasLimit, _donId);
        _lastRequestId = requestId;

        _afterUpdate(requestId, args);
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

    // #region getter functions
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
     * @notice Returns the id of the last request made to Chainlink Functions.
     * @return The id of the last request made to Chainlink Functions.
     */
    function lastRequestId() public view returns (bytes32) {
        return _lastRequestId;
    }
    // #endregion

    // #region internal hook functions
    function _afterUpdate(bytes32, /*requestId*/ string[] memory /*args*/ ) internal virtual {}
    // #endregion

    // #region private functions
    function _setDonId(bytes32 donId_) private {
        if (donId_ == bytes32(0)) revert InvalidDonId();

        _donId = donId_;
    }

    function _setSubscriptionId(uint64 subscriptionId_) private {
        if (subscriptionId_ == uint64(0)) revert InvalidSubscriptionId();

        _subscriptionId = subscriptionId_;
    }

    function _setCallbackGasLimit(uint32 callbackGasLimit_) private {
        if (callbackGasLimit_ == uint32(0)) revert InvalidCallbackGasLimit();

        _callbackGasLimit = callbackGasLimit_;
    }

    function _setSource(string memory source_) private {
        if (bytes(source_).length == 0) revert InvalidSource();

        _source = source_;
    }
    // #endregion
}
