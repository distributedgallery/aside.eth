// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Burnable.sol";
import {IAsideErrors} from "./IAsideErrors.sol";
import {AsideFunctions, FunctionsRequest} from "./AsideFunctions.sol";

/// @custom:security-contact contact@distributedgallery.art
contract Aside0x01 is IAsideErrors, AsideFunctions, ERC721, ERC721URIStorage, ERC721Burnable, AccessControl {
    using FunctionsRequest for FunctionsRequest.Request;

    event Unlock(uint256 indexed tokenId, uint256 sentiment);
    event EmergencyUnlock(bool unlocked);

    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");
    uint32 public constant SENTIMENT_UNIT = 100;
    uint32 public constant SENTIMENT_INTERVAL = 10;
    uint32 public constant TIMELOCK = 730 days;
    uint32 public constant CALLBACK_GAS_LIMIT = 100_000;
    uint256 private immutable LOCK_DEADLINE;

    bool private _eUnlocked = false; // emergency unlock
    mapping(uint256 => bool) private _unlocks; // tokenId => isUnlocked
    mapping(uint256 => uint256) private _sentiments; // tokenId => sentiment
    mapping(bytes32 => uint256) private _tokenIds; // requestId => tokenId
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
        AsideFunctions(router_, donId_, subscriptionId_)
        ERC721("Aside0x01", "ASD")
    {
        _grantRole(DEFAULT_ADMIN_ROLE, admin);
        _grantRole(MINTER_ROLE, minter);
        LOCK_DEADLINE = block.timestamp + TIMELOCK;
    }

    /**
     * @notice Mints `tokenId`, transfers it to `to` and checks for `to` acceptance.
     * @dev `sentiment` must be in the range of 0 to SENTIMENT_UNIT.
     * @dev `tokenId` must not exist.
     * @dev If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon a safe transfer.
     * @dev Emits a {Transfer} event.
     * @param to The address to receive the token to be minted.
     * @param tokenId The id of the token to be minted.
     * @param sentiment The AI sentiment to associate to token `tokenId`.
     * @param uri The token URI to associate to token `tokenId`.
     */
    function mint(address to, uint256 tokenId, uint256 sentiment, string memory uri) public onlyRole(MINTER_ROLE) {
        if (sentiment > SENTIMENT_UNIT) revert InvalidSentiment(sentiment);
        // Check token >=1 to make sure there are no mismatchs in requestId => tokenId mapping ?
        _sentiments[tokenId] = sentiment;
        _safeMint(to, tokenId);
        _setTokenURI(tokenId, uri);
    }

    /**
     * @notice Requests the unlock of token #`tokenId`.
     * @dev Token #`tokenId` must exist.
     * @dev Token #`tokenId` must be locked.
     * @dev The AI sentiment fetched from Chainlink Functions must be in the range of token #`tokenId`'s associated sentiment.
     * @param tokenId The id of the token to unlock.
     */
    function requestUnlock(uint256 tokenId) external {
        if (_ownerOf(tokenId) == address(0)) revert ERC721NonexistentToken(tokenId);
        if (_isUnlocked(tokenId)) revert TokenUnlocked(tokenId);

        FunctionsRequest.Request memory req;
        req.initializeRequestForInlineJavaScript(_source);
        bytes32 requestId = _sendRequest(req.encodeCBOR(), _subscriptionId, CALLBACK_GAS_LIMIT, _donId);
        _tokenIds[requestId] = tokenId;
    }

    /**
     * @notice Callback function for fulfilling a request.
     * @param requestId The ID of the request to fulfill.
     * @param response The HTTP response data.
     * @param err Any errors from the Functions request.
     */
    function fulfillRequest(bytes32 requestId, bytes memory response, bytes memory err) internal override {
        // if (requestId != _currentRequestId) revert InvalidRequestId(_currentRequestId, requestId); // check if requests match
        if (err.length > 0) revert RequestError(err); // check if there is an error in the request
        uint256 tokenId = _tokenIds[requestId];
        if (_ownerOf(tokenId) == address(0)) revert ERC721NonexistentToken(tokenId);
        if (_isUnlocked(tokenId)) revert TokenUnlocked(tokenId);
        uint256 sentiment = uint256(bytes32(response));
        uint256 expectedSentiment = _sentiments[tokenId];
        if (sentiment < expectedSentiment || sentiment >= expectedSentiment + SENTIMENT_INTERVAL) {
            revert TokenNotUnlocked(tokenId, requestId, sentiment);
        } // check if sentiment is in the expected range

        _unlocks[tokenId] = true;
        emit Unlock(tokenId, sentiment);
    }

    // #region admin-only functions
    /**
     * @notice Unlocks all the tokens at once.
     * @dev This function is only to be used in case of an emergency.
     */
    function unlock() external onlyRole(DEFAULT_ADMIN_ROLE) {
        _eUnlocked = true;

        emit EmergencyUnlock(true);
    }

    /**
     * @notice Cancels any emergency unlock.
     * @dev This function is only to be used in case an emergency unlock has been triggered by mistake.
     */
    function relock() external onlyRole(DEFAULT_ADMIN_ROLE) {
        _eUnlocked = false;

        emit EmergencyUnlock(false);
    }

    /**
     * @notice Sets the source of the Chainlink Functions call.
     * @param source_ The source of the Chainlink Functions call.
     */
    function setSource(string memory source_) external onlyRole(DEFAULT_ADMIN_ROLE) {
        _source = source_;
    }

    /**
     * @inheritdoc AsideFunctions
     */
    function setRouter(address router_) external override onlyRole(DEFAULT_ADMIN_ROLE) {
        _setRouter(router_);
    }

    /**
     * @inheritdoc AsideFunctions
     */
    function setDonId(bytes32 donId_) external override onlyRole(DEFAULT_ADMIN_ROLE) {
        _setDonId(donId_);
    }

    /**
     * @inheritdoc AsideFunctions
     */
    function setSubscriptionId(uint64 subscriptionId_) external override onlyRole(DEFAULT_ADMIN_ROLE) {
        _setSubscriptionId(subscriptionId_);
    }
    // #endregion

    // #region getters
    /**
     * @notice Checks whether all the tokens have been unlocked at once by emergency or not.
     * @return A boolean indicating whether all the tokens have been unlocked at once by emergency or not.
     */
    function eUnlocked() public view returns (bool) {
        return _eUnlocked;
    }

    /**
     * @notice Checks whether all the tokens are unlocked, either because of an emergency unlock or because the lock deadline has been reached.
     * @return A boolean indicating whether all the tokens are unlocked or not.
     */
    function areAllUnlocked() public view returns (bool) {
        return _areAllUnlocked();
    }

    /**
     * @notice Checks whether token `tokenId` is unlocked or not.
     * @dev `tokenId` must exist.
     * @param tokenId The id of the token to check whether it is unlocked or not.
     * @return A boolean indicating whether token `tokenId` is unlocked or not.
     */
    function isUnlocked(uint256 tokenId) public view returns (bool) {
        _requireOwned(tokenId);

        return _isUnlocked(tokenId);
    }

    /**
     * @notice Returns the source of the Chainlink Functions call.
     * @return The source of the Chainlink Functions call.
     */
    function source() public view returns (string memory) {
        return _source;
    }

    /**
     * @notice Returns the sentiment associated to token `tokenId`.
     * @dev `tokenId` must exist.
     * @return The sentiment associated to token `tokenId`.
     */
    function sentimentOf(uint256 tokenId) public view returns (uint256) {
        _requireOwned(tokenId);

        return _sentiments[tokenId];
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
    function _areAllUnlocked() private view returns (bool) {
        return block.timestamp >= LOCK_DEADLINE || _eUnlocked;
    }

    function _isUnlocked(uint256 tokenId) private view returns (bool) {
        return _unlocks[tokenId] || _areAllUnlocked();
    }

    function _setSource(string memory source_) private {
        _source = source_;
    }

    function _update(address to, uint256 tokenId, address auth) internal override(ERC721) returns (address) {
        if (_ownerOf(tokenId) != address(0) && !_isUnlocked(tokenId)) {
            revert TokenLocked(tokenId);
        }
        return super._update(to, tokenId, auth);
    }
    // #endregion

    // #region required overrides
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
