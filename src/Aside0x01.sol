// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {AsideBase, AsideChainlink, FunctionsRequest} from "./AsideChainlink.sol";

contract Aside0x01 is AsideChainlink {
    error InvalidSentiment();

    uint8 public constant SENTIMENT_UNIT = 100;
    uint8 public constant SENTIMENT_INTERVAL = 10;

    mapping(uint256 => uint256) private _sentiments; // tokenId => sentiment

    /**
     * @notice Creates a new Aside0x01 contract.
     * @param baseURI_ The base URI of the token.
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
        string memory baseURI_,
        address admin_,
        address minter_,
        uint256 timelock_,
        address router_,
        bytes32 donId_,
        uint64 subscriptionId_,
        uint32 callbackGasLimit_,
        string memory source_
    )
        AsideChainlink(
            "Aside0x01",
            "ASD0x01",
            baseURI_,
            admin_,
            minter_,
            timelock_,
            router_,
            donId_,
            subscriptionId_,
            callbackGasLimit_,
            source_
        )
    {}

    /**
     * @inheritdoc AsideBase
     * @dev `tokenId` must be >= 1.
     *  The payload must be a string of the form "SSSURI", where SSS is a 3 digits string defining the sentiment to associate to token
     * `tokenId`.
     * @dev The sentiment must be in the [0, 100] range.
     */
    function mint(address to, uint256 tokenId, string calldata payload) external override isValidTokenId(tokenId) onlyRole(MINTER_ROLE) {
        _sentiments[tokenId] = _safeCastSentiment(payload);
        _safeMint(to, tokenId);
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
        _ensureLocked(tokenId);
        uint256 sentiment = uint256(bytes32(response));
        uint256 expectedSentiment = _sentiments[tokenId];
        if (sentiment < expectedSentiment || sentiment >= expectedSentiment + SENTIMENT_INTERVAL) {
            revert InvalidUnlockRequest(tokenId, requestId);
        }

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

    // #region private functions
    function _safeCastSentiment(string memory _sentiment) private pure returns (uint8) {
        if (bytes(_sentiment).length != 3) revert InvalidPayload(_sentiment);

        bytes memory b = bytes(_sentiment);
        uint8 sentiment = 0;

        for (uint8 i = 0; i < 3; i++) {
            uint8 c = uint8(b[i]);
            if (c >= 48 && c <= 57) sentiment = sentiment * 10 + (c - 48);
            else revert InvalidPayload(_sentiment);
        }

        if (sentiment > SENTIMENT_UNIT) revert InvalidSentiment();

        return sentiment;
    }
    // #endregion
}
