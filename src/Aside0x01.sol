// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Burnable.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
// import {FunctionsClient} from "chainlink/contracts/src/v0.8/functions/dev/1_0_0/FunctionsClient.sol";
// import {ConfirmedOwner} from "chainlink/contracts/src/v0.8/shared/access/ConfirmedOwner.sol";
// import {FunctionsRequest} from "chainlink/contracts/src/v0.8/functions/dev/1_0_0/libraries/FunctionsRequest.sol";
import {AsideFunctions, FunctionsRequest} from "./AsideFunctions.sol";

/// @custom:security-contact contact@distributedgallery.art
contract Aside0x01 is AsideFunctions, ERC721, ERC721URIStorage, ERC721Burnable, AccessControl {
    using FunctionsRequest for FunctionsRequest.Request;

    error TokenLocked(uint256 tokenId);
    error TokenNotUnlocked(uint256 tokenId, bytes32 requestId, uint256 sentiment);
    error TokenUnlocked(uint256 tokenId);
    error InvalidSubscriptionId(uint64 subscriptionId);
    error InvalidSentiment(uint256 sentiment);
    error InvalidRequestId(bytes32 currentRequestId, bytes32 requestId);
    error RequestError(bytes err);

    event Unlock(uint256 indexed tokenId, uint256 sentiment);
    event EmergencyUnlock();

    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");
    uint32 public constant SENTIMENT_INTERVAL = 10;
    uint32 public constant SENTIMENT_UNIT = 100;
    uint32 public constant TIMELOCK = 730 days;
    uint32 public constant CALLBACK_GAS_LIMIT = 100_000;
    // uint32 public constant MIN_REQUEST_INTERVAL = 1 days;
    uint256 private immutable LOCK_DEADLINE;
    uint64 private _subscriptionId;
    bool private _eUnlocked = false; // emergency unlock
    mapping(uint256 => bool) private _unlocks; // tokenId => isUnlocked
    mapping(uint256 => uint256) private _sentimentOf; // tokenId => sentiment
    mapping(bytes32 => uint256) private _tokenIdOf; // requestId => tokenId
    string private _source =
        "const response = await Functions.makeHttpRequest({url: 'https://aside-js.vercel.app/api/aisentiment', method: 'GET'});if (response.error) {throw Error('Request failed');}return Functions.encodeUint256(response.data.sentiment.toFixed(2)*100);";

    /**
     * @notice Creates a new Aside0x01 contract.
     * @param admin The address of the admin.
     * @param minter The address of the minter.
     * @param router_ The address of the Chainlink Functions router.
     * @param donId_ The ID of the Chainlink Functions DON.
     */
    constructor(address admin, address minter, address router_, bytes32 donId_, uint64 subscriptionId_)
        AsideFunctions(router_, donId_)
        ERC721("Aside0x01", "ASD")
    {
        if (subscriptionId_ == 0) revert InvalidSubscriptionId(subscriptionId_);
        _setSubscriptionId(subscriptionId_);
        _grantRole(DEFAULT_ADMIN_ROLE, admin);
        _grantRole(MINTER_ROLE, minter);
        LOCK_DEADLINE = block.timestamp + TIMELOCK;
    }

    /**
     *
     * @param to The address to receive the token.
     * @param tokenId The token id.
     * @param sentiment The AI sentiment tied to the token.
     * @param uri The token URI.
     */
    function mint(address to, uint256 tokenId, uint256 sentiment, string memory uri) public onlyRole(MINTER_ROLE) {
        if (sentiment > SENTIMENT_UNIT) revert InvalidSentiment(sentiment);
        _sentimentOf[tokenId] = sentiment;
        _safeMint(to, tokenId);
        _setTokenURI(tokenId, uri);
    }

    // function sendRequest(uint64 subscriptionId, string[] calldata /*args*/ ) external returns (bytes32 requestId) {
    //     FunctionsRequest.Request memory req;

    //     req.initializeRequestForInlineJavaScript(source);
    //     // Send the request and store the request ID
    //     _currentRequestId = _sendRequest(req.encodeCBOR(), subscriptionId, CALLBACK_GAS_LIMIT, _donId);
    //     _tokenIdOfRequest[_currentRequestId] = tokenId;
    // }

    function requestUnlock(uint256 tokenId) external {
        if (_ownerOf(tokenId) == address(0)) revert ERC721NonexistentToken(tokenId);
        if (_isUnlocked(tokenId)) revert TokenUnlocked(tokenId);

        FunctionsRequest.Request memory req;
        req.initializeRequestForInlineJavaScript(_source);
        _currentRequestId = _sendRequest(req.encodeCBOR(), _subscriptionId, CALLBACK_GAS_LIMIT, _donId);
        _tokenIdOf[_currentRequestId] = tokenId;
    }

    /**
     * @notice Callback function for fulfilling a request
     * @param requestId The ID of the request to fulfill
     * @param response The HTTP response data
     * @param err Any errors from the Functions request
     */
    function fulfillRequest(bytes32 requestId, bytes memory response, bytes memory err) internal override {
        if (requestId != _currentRequestId) revert InvalidRequestId(_currentRequestId, requestId); // check if requests match
        if (err.length > 0) revert RequestError(err); // check if there is an error in the request
        uint256 tokenId = _tokenIdOf[requestId];
        uint256 sentiment = uint256(bytes32(response));
        uint256 expectedSentiment = _sentimentOf[tokenId];
        if (sentiment < expectedSentiment || sentiment >= expectedSentiment + SENTIMENT_INTERVAL) {
            revert TokenNotUnlocked(tokenId, requestId, sentiment);
        } // check if sentiment is in the expected range

        _unlocks[tokenId] = true;
        emit Unlock(tokenId, sentiment);
    }

    function setSubscriptionId(uint64 subscriptionId_) public onlyRole(DEFAULT_ADMIN_ROLE) {
        if (subscriptionId_ == 0) revert InvalidSubscriptionId(subscriptionId_);

        _setSubscriptionId(subscriptionId_);
    }

    // #region Getters
    function subscriptionId() public view returns (uint64) {
        return _subscriptionId;
    }

    function sentimentOf(uint256 tokenId) public view returns (uint256) {
        if (_ownerOf(tokenId) == address(0)) revert ERC721NonexistentToken(tokenId);

        return _sentimentOf[tokenId];
    }

    /**
     * @dev Checks whether token `tokenId` is unlocked or not.
     * @param tokenId The id of the token to check.
     * @return A boolean indicating whether the token is unlocked or not.
     */
    function isUnlocked(uint256 tokenId) public view returns (bool) {
        return _isUnlocked(tokenId);
    }

    function _isUnlocked(uint256 tokenId) private view returns (bool) {
        return _unlocks[tokenId] || _areAllUnlocked();
    }

    function eUnlocked() public view returns (bool) {
        return _eUnlocked;
    }

    function _areAllUnlocked() private view returns (bool) {
        return _eUnlocked || block.timestamp >= LOCK_DEADLINE;
    }
    // #endregion
    // #endregion

    // #region LockGetters

    function _update(address to, uint256 tokenId, address auth) internal override(ERC721) returns (address) {
        if (_ownerOf(tokenId) != address(0) && !_isUnlocked(tokenId)) {
            revert TokenLocked(tokenId);
        }
        return super._update(to, tokenId, auth);
    }

    // #region AsideFunctions
    /**
     * @inheritdoc AsideFunctions
     */
    function setRouter(address router_) external override onlyRole(DEFAULT_ADMIN_ROLE) {
        if (router_ == address(0)) revert InvalidRouter(router_);

        _setRouter(router_);
    }

    /**
     * @inheritdoc AsideFunctions
     */
    function setDonId(bytes32 donId_) external override onlyRole(DEFAULT_ADMIN_ROLE) {
        if (donId_ == bytes32(0)) revert InvalidDonId(donId_);

        _setDonId(donId_);
    }

    function _setSubscriptionId(uint64 subscriptionId_) private {
        _subscriptionId = subscriptionId_;
    }
    // #endregion

    // #region RequiredOverrides
    function tokenURI(uint256 tokenId) public view override(ERC721, ERC721URIStorage) returns (string memory) {
        return super.tokenURI(tokenId);
    }

    function supportsInterface(bytes4 interfaceId)
        public
        view
        override(ERC721, ERC721URIStorage, AccessControl)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }
    // #endregion
}
