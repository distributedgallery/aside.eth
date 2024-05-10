// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {AsideBase, AsideChainlink} from "./AsideChainlink.sol";

contract Aside0x01 is AsideChainlink {
    uint8 public constant SENTIMENT_UNIT = 100;
    uint8 public constant SENTIMENT_INTERVAL = 10;

    uint256 private _lastSentiment;
    uint256 private _lastSentimentTimestamp;
    mapping(uint256 => uint256) private _sentiments; // tokenId => sentiment

    /**
     * @notice Creates a new Aside0x01 contract.
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
    )
        AsideChainlink(
            "Aside0x01",
            "ASD0x01",
            baseURI_,
            admin_,
            minter_,
            unlocker_,
            timelock_,
            router_,
            donId_,
            subscriptionId_,
            callbackGasLimit_,
            source_
        )
    {}

    /**
     * @notice Callback function for fulfilling a Chainlink Functions request.
     * @param requestId The id of the request to fulfill.
     * @param response The HTTP response data.
     * @param err Any errors from the Chainlink Functions request.
     */
    function fulfillRequest(bytes32 requestId, bytes memory response, bytes memory err)
        internal
        override
        onlyValidRequestId(requestId)
        onlyValidCallback(err)
    {
        _lastSentiment = uint256(bytes32(response));
        _lastSentimentTimestamp = block.timestamp;
    }

    // #region getters
    /**
     * @notice Exprimental function for testing purposes
     */
    function fromBytes(bytes memory b) public pure returns (uint256) {
        return uint256(bytes32(b));
    }

    /**
     * @notice Returns the last AI sentiment fetched through Chainlink Functions and its timestamp.
     * @return sentiment The last AI sentiment fetched through Chainlink Functions.
     * @return timestamp The timestamp of the last AI sentiment fetched through Chainlink Functions.
     */
    function lastSentiment() public view returns (uint256 sentiment, uint256 timestamp) {
        sentiment = _lastSentiment;
        timestamp = _lastSentimentTimestamp;
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
    // #endregion

    // #region internal hook functions
    /**
     * @dev The payload must be a bytes encoded uint256 in the [0, 100] range.
     */
    function _afterMint(address to, uint256 tokenId, bytes memory payload) internal override(AsideBase) {
        uint256 sentiment = uint256(bytes32(payload));
        if (sentiment > SENTIMENT_UNIT) revert InvalidPayload(payload);
        _sentiments[tokenId] = sentiment;

        super._afterMint(to, tokenId, payload);
    }

    function _beforeUnlock(uint256[] memory tokenIds) internal override(AsideBase) {
        super._beforeUnlock(tokenIds);

        if (block.timestamp > _lastSentimentTimestamp + 1 hours) revert DeprecatedData();

        uint256 length = tokenIds.length;
        for (uint256 i = 0; i < length; i++) {
            uint256 tokenId = tokenIds[i];
            uint256 current = _lastSentiment;
            uint256 expected = _sentiments[tokenId];
            if (current < expected || current >= expected + SENTIMENT_INTERVAL) {
                revert InvalidUnlock(tokenId);
            }
        }
    }
    // #endregion
}
