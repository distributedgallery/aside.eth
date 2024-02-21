// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {AsideChainlink, FunctionsRequest} from "./AsideChainlink.sol";

/// @custom:security-contact contact@distributedgallery.art
contract Aside0x01 is AsideChainlink {
    using FunctionsRequest for FunctionsRequest.Request;

    error InvalidSentiment();

    uint32 public constant SENTIMENT_UNIT = 100;
    uint32 public constant SENTIMENT_INTERVAL = 10;

    mapping(uint256 => uint256) private _sentiments; // tokenId => sentiment

    uint32 public constant CALLBACK_GAS_LIMIT = 100_000;
    string public constant SOURCE =
        "const response = await Functions.makeHttpRequest({url:'https://aside-js.vercel.app/api/aisentiment', method: 'GET'});if (response.error) {throw Error('Request failed');}return Functions.encodeUint256(response.data.sentiment.toFixed(2)*100);";

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
     * @dev `sentiment` must be in the range of 0 to SENTIMENT_UNIT.
     * @dev `tokenId` must not exist.
     * @dev If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received},
     * which is called upon a safe transfer.
     * @dev Emits a {Transfer} event.
     * @param to The address to receive the token to be minted.
     * @param tokenId The id of the token to be minted.
     * @param sentiment The AI sentiment to associate to token `tokenId`.
     * @param uri The token URI to associate to token `tokenId`.
     */
    function mint(address to, uint256 tokenId, uint256 sentiment, string memory uri) public onlyRole(MINTER_ROLE) {
        if (sentiment > SENTIMENT_UNIT) revert InvalidSentiment();
        // Check token >=1 to make sure there are no mismatchs in requestId => tokenId mapping ?
        _sentiments[tokenId] = sentiment;
        _safeMint(to, tokenId);
        _setTokenURI(tokenId, uri);
    }

    function stringToUint(string memory s) public pure returns (uint256) {
        bytes memory b = bytes(s);
        uint256 result = 0;
        for (uint256 i = 0; i < b.length; i++) {
            uint256 c = uint256(uint8(b[i]));
            if (c >= 48 && c <= 57) result = result * 10 + (c - 48);
        }
        return result;
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
    function requestUnlock(uint256 tokenId) external {
        if (_ownerOf(tokenId) == address(0)) revert ERC721NonexistentToken(tokenId);
        if (_isUnlocked(tokenId)) revert TokenAlreadyUnlocked(tokenId);

        FunctionsRequest.Request memory req;
        req.initializeRequestForInlineJavaScript(_source);
        bytes32 requestId = _sendRequest(req.encodeCBOR(), _subscriptionId, _callbackGasLimit, _donId);
        _tokenIds[requestId] = tokenId;
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
        uint256 tokenId = _tokenIds[requestId];
        if (_ownerOf(tokenId) == address(0)) revert ERC721NonexistentToken(tokenId);
        if (_isUnlocked(tokenId)) revert TokenAlreadyUnlocked(tokenId);
        uint256 sentiment = uint256(bytes32(response));
        uint256 expectedSentiment = _sentiments[tokenId];
        if (sentiment < expectedSentiment || sentiment >= expectedSentiment + SENTIMENT_INTERVAL) {
            revert InvalidUnlockRequest(tokenId, requestId);
        } // check if sentiment is in the expected range

        _unlocks[tokenId] = true;
        emit Unlock(tokenId);
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
