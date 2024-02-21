// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {AsideChainlink, FunctionsRequest} from "./AsideChainlink.sol";

contract Aside0x01 is AsideChainlink {
    using FunctionsRequest for FunctionsRequest.Request;

    error InvalidSentiment();

    uint8 public constant SENTIMENT_UNIT = 100;
    uint8 public constant SENTIMENT_INTERVAL = 10;

    mapping(uint256 => uint8) private _sentiments; // tokenId => sentiment

    /**
     * @notice Creates a new Aside0x01 contract.
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
        address admin_,
        address minter_,
        uint256 timelock_,
        address router_,
        bytes32 donId_,
        uint64 subscriptionId_,
        uint32 callbackGasLimit_,
        string memory source_
    ) AsideChainlink("Aside0x01", "ASD0x01", admin_, minter_, timelock_, router_, donId_, subscriptionId_, callbackGasLimit_, source_) {}

    /**
     * @notice Mints `tokenId`, transfers it to `to` and checks for `to` acceptance.
     * @dev `to` must not be the zero address.
     * @dev `tokenId` must not exist.
     * @dev `tokenId` must be >= 1.
     * @dev `sentiment` must be in the [0, SENTIMENT_UNIT] range.
     * @dev Emits a {Transfer} event.
     * @param to The address to receive the token to be minted.
     * @param tokenId The id of the token to be minted.
     * @param payload The payload to be used to mint the token. This payload must be a string of the form "SSSURI", where SSS is the
     * sentiment of the token and URI is the URI of the token.
     */
    // function mint(address to, uint256 tokenId, uint256 sentiment, string memory uri)
    function mint(address to, uint256 tokenId, string calldata payload) external isValidTokenId(tokenId) onlyRole(MINTER_ROLE) {
        uint8 sentiment = _sentimentFromString(payload[0:3]);
        string memory uri = payload[3:bytes(payload).length];

        _sentiments[tokenId] = sentiment;

        _safeMint(to, tokenId);
        _setTokenURI(tokenId, uri);
    }

    function _sentimentFromString(string memory _sentiment) private pure returns (uint8) {
        bytes memory b = bytes(_sentiment);
        uint8 sentiment = 0;

        for (uint8 i = 0; i < 3; i++) {
            uint8 c = uint8(b[i]);
            if (c >= 48 && c <= 57) sentiment = sentiment * 10 + (c - 48);
            else revert InvalidSentiment();
        }
        if (sentiment > SENTIMENT_UNIT) revert InvalidSentiment();

        return sentiment;
    }

    //   function trim(string calldata str, uint start, uint end) external pure returns(string memory)
    // {
    //     return str[start:end];
    // }

    /**
     * @notice Requests the unlock of token #`tokenId`.
     * @dev Token #`tokenId` must exist.
     * @dev Token #`tokenId` must be locked.
     * @dev The AI sentiment fetched from Chainlink Functions must be in the range of token
     * #`tokenId`'s associated sentiment.
     * @param tokenId The id of the token to unlock.
     */
    function requestUnlock(uint256 tokenId) external override isLocked(tokenId) {
        FunctionsRequest.Request memory req;
        req.initializeRequestForInlineJavaScript(source());
        _requestUnlock(tokenId, req);
    }

    /**
     * @notice Callback function for fulfilling a request.
     * @param requestId The ID of the request to fulfill.
     * @param response The HTTP response data.
     * @param err Any errors from the Functions request.
     */
    function fulfillRequest(bytes32 requestId, bytes memory response, bytes memory err) internal override {
        // if (requestId != _currentRequestId) revert InvalidRequestId(_currentRequestId, requestId); //
        // check if requests match
        if (err.length > 0) revert InvalidUnlockCallback(err); // check if there is an error in the
            // request
        uint256 tokenId = _tokenIdOf(requestId);
        if (_ownerOf(tokenId) == address(0)) revert ERC721NonexistentToken(tokenId);
        if (_isUnlocked(tokenId)) revert TokenAlreadyUnlocked(tokenId);
        uint256 sentiment = uint256(bytes32(response));
        uint256 expectedSentiment = _sentiments[tokenId];
        if (sentiment < expectedSentiment || sentiment >= expectedSentiment + SENTIMENT_INTERVAL) {
            revert InvalidUnlockRequest(tokenId, requestId);
        } // check if sentiment is in the expected range

        _unlock(tokenId);
    }
    // #endregion

    // #region getters
    /**
     * @notice Returns the sentiment associated to token `tokenId`.
     * @dev `tokenId` must exist.
     * @return The sentiment associated to token `tokenId`.
     */
    function sentimentOf(uint256 tokenId) public view returns (uint256) {
        _requireOwned(tokenId);

        return _sentiments[tokenId];
    }
    // #endregion
}
