// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Aside} from "./Aside.sol";
import {FunctionsClient} from "chainlink/src/v0.8/functions/v1_0_0/FunctionsClient.sol";
import {FunctionsRequest} from "chainlink/src/v0.8/functions/v1_0_0/libraries/FunctionsRequest.sol";

/// @custom:security-contact contact@distributedgallery.art
abstract contract AsideChainlink is Aside, FunctionsClient {
  // using FunctionsRequest for FunctionsRequest.Request;

  error InvalidRouter();
  error InvalidDonId();
  error InvalidSubscriptionId();
  error InvalidUnlockRequest(uint256 tokenId, bytes32 requestId);
  error InvalidChainlinkRequest(bytes err);

  address internal _router;
  bytes32 internal _donId;
  uint64 internal _subscriptionId;
  uint32 internal _callbackGasLimit;
  string internal _source;

  mapping(bytes32 => uint256) internal _tokenIds; // requestId => tokenId

  /**
   * @notice Creates a new AsideFunction contract.
   * @param router_ The address of the Chainlink Functions router.
   * @param donId_ The id of the Chainlink Functions DON.
   * @param subscriptionId_ The id of the Chainlink Functions subscription.
   */
  constructor(
    string memory name_,
    string memory symbol_,
    address admin,
    address minter,
    uint256 timelock,
    address router_,
    bytes32 donId_,
    uint64 subscriptionId_
  ) Aside(name_, symbol_, admin, minter, timelock) FunctionsClient(router_) {
    _setRouter(router_);
    _setDonId(donId_);
    _setSubscriptionId(subscriptionId_);
  }

  // #region admin-only functions
  /**
   * @notice Sets the Chainlink Functions router address.
   * @dev The implementation of this function should be protected by some access control mechanism.
   * @param router_ The address of the Chainlink Functions router.
   */
  function setRouter(address router_) external onlyRole(DEFAULT_ADMIN_ROLE) {
    _setRouter(router_);
  }

  /**
   * @notice Sets the Chainlink Functions DON id.
   * @dev The implementation of this function should be protected by some access control mechanism.
   * @param donId_ The id of the Chainlink Functions DON.
   */
  function setDonId(bytes32 donId_) external onlyRole(DEFAULT_ADMIN_ROLE) {
    _setDonId(donId_);
  }

  /**
   * @notice Sets the Chainlink Functions subscription id.
   * @dev The implementation of this function should be protected by some access control mechanism.
   * @param subscriptionId_ The id of the Chainlink Functions subscription.
   */
  function setSubscriptionId(uint64 subscriptionId_) external onlyRole(DEFAULT_ADMIN_ROLE) {
    _setSubscriptionId(subscriptionId_);
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

  // #region private / internal functions
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

  function _setSource(string memory source_) private {
    _source = source_;
  }
  // #endregion
}
