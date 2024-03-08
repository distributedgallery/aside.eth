// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {AsideBase} from "./AsideBase.sol";
import {FunctionsClient} from "chainlink/src/v0.8/functions/v1_0_0/FunctionsClient.sol";
import {FunctionsRequest} from "chainlink/src/v0.8/functions/v1_0_0/libraries/FunctionsRequest.sol";

abstract contract AsideChainlink is AsideBase, FunctionsClient {
    using FunctionsRequest for FunctionsRequest.Request;

    error InvalidDonId();
    error InvalidSubscriptionId();
    error InvalidCallbackGasLimit();
    error InvalidSource();
    error InvalidTokenIds();
    error InvalidRequestId(bytes32 requestId);
    error InvalidUnlockCallback(bytes err);
    error InvalidUnlockRequest(uint256 tokenId, bytes32 requestId);

    bytes32 private _donId;
    uint64 private _subscriptionId;
    uint32 private _callbackGasLimit;
    string private _source;
    mapping(bytes32 => uint256[]) private _tokenIds; // requestId => tokenIds

    /**
     * @notice Creates a new AsideChainlink contract.
     * @param name_ The name of the token.
     * @param symbol_ The symbol of the token.
     * @param baseURI_ The base URI of the token.
     * @param admin_ The address to set as the DEFAULT_ADMIN of this contract.
     * @param minter_ The address to set as the MINTER of this contract.
     * @param unlocker_ The address to set as the UNLOCKER of this contract.
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
        address unlocker_,
        uint256 timelock_,
        address router_,
        bytes32 donId_,
        uint64 subscriptionId_,
        uint32 callbackGasLimit_,
        string memory source_
    ) AsideBase(name_, symbol_, baseURI_, admin_, minter_, unlocker_, timelock_) FunctionsClient(router_) {
        _setDonId(donId_);
        _setSubscriptionId(subscriptionId_);
        _setCallbackGasLimit(callbackGasLimit_);
        _setSource(source_);
    }

    /**
     * @inheritdoc AsideBase
     * @dev This function triggers a Chainlink Functions call. The unlocks only occur after the callback function is called [if the
     * conditions to unlock tokens `tokenIds` are met].
     */
    function unlock(uint256[] calldata tokenIds) external virtual override(AsideBase) onlyRole(UNLOCKER_ROLE) {
        uint256 length = tokenIds.length;
        if (length == uint256(0)) revert InvalidTokenIds();
        for (uint256 i = 0; i < length; i++) {
            _ensureLocked(tokenIds[i]);
        }
        _requestUnlock(tokenIds);
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
     * @notice Returns the tokenId associated to the request `requestId`.
     * @dev `requestId` must exist.
     * @param requestId The id of the request to get the tokenId associated to.
     * @return The tokenId associated to the request `requestId`.
     */
    function tokenIdsOf(bytes32 requestId) public view returns (uint256[] memory) {
        return _tokenIdsOf(requestId);
    }
    // #endregion

    // #region internal / private functions
    function _requestUnlock(uint256[] memory tokenIds) internal virtual {
        FunctionsRequest.Request memory request;
        request.initializeRequestForInlineJavaScript(_source);
        _setTokenIds(_sendRequest(request.encodeCBOR(), _subscriptionId, _callbackGasLimit, _donId), tokenIds);
    }

    function _tokenIdsOf(bytes32 requestId) internal view returns (uint256[] storage) {
        uint256[] storage tokenIds = _tokenIds[requestId];
        if (tokenIds.length == uint256(0)) revert InvalidRequestId(requestId);

        return tokenIds;
    }

    function _setTokenIds(bytes32 requestId, uint256[] memory tokenIds) internal {
        _tokenIds[requestId] = tokenIds;
    }

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
