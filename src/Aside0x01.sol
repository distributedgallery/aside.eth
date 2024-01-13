// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Burnable.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import {FunctionsClient} from "chainlink/contracts/src/v0.8/functions/dev/1_0_0/FunctionsClient.sol";
import {ConfirmedOwner} from "chainlink/contracts/src/v0.8/shared/access/ConfirmedOwner.sol";
import {FunctionsRequest} from "chainlink/contracts/src/v0.8/functions/dev/1_0_0/libraries/FunctionsRequest.sol";

struct AISentiment {
    uint256 value;
    uint256 timestamp;
}

struct Oracle {
    bytes32 lastRequestId;
    bytes lastResponse;
    bytes lastError;
}

/// @custom:security-contact contact@distributedgallery.art
contract Aside0x01 is FunctionsClient, ConfirmedOwner, ERC721, ERC721URIStorage, ERC721Burnable, AccessControl {
    using FunctionsRequest for FunctionsRequest.Request;

    error TokenLocked(uint256 tokenId);
    error UnexpectedRequestID(bytes32 requestId);
    error InvalidRouter(address router);
    error InvalidDonID(bytes32 donID);

    event Response(bytes32 indexed requestId, uint256 sentiment, bytes response, bytes err);

    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");

    address public router;
    bytes32 public donID;
    mapping(uint256 => uint256) private _timelocks;
    uint32 public gasLimit = 100000;
    AISentiment public sentiment;
    Oracle public oracle;

    string private source =
        "const response = await Functions.makeHttpRequest({url: 'https://aside-js.vercel.app/api/aisentiment', method: 'GET'});if (response.error) {throw Error('Request failed');}return Functions.encodeUint256(response.data.sentiment.toFixed(2)*100);";

    /**
     * @notice Creates a new Aside0x01 contract
     * @param admin The address of the admin role
     * @param minter The address of the minter role
     * @param _router The address of the Chainlink Functions router
     * @param _donID The id of the Chainlink Functions DON
     */
    constructor(address admin, address minter, address _router, bytes32 _donID)
        FunctionsClient(_router)
        ConfirmedOwner(msg.sender)
        ERC721("Aside0x01", "ASD")
    {
        if (_router == address(0)) revert InvalidRouter(_router);
        if (_donID == bytes32(0)) revert InvalidDonID(_donID);

        _setRouter(_router);
        _setDonID(_donID);
        _grantRole(DEFAULT_ADMIN_ROLE, admin);
        _grantRole(MINTER_ROLE, minter);
    }

    /**
     *
     * @param to The address to receive the token.
     * @param tokenId The token id.
     * @param timelock The timelock duration in seconds.
     * @param uri The token URI.
     */
    function mint(address to, uint256 tokenId, uint256 timelock, string memory uri) public onlyRole(MINTER_ROLE) {
        _safeMint(to, tokenId);
        _setTokenURI(tokenId, uri);
        _timelocks[tokenId] = block.timestamp + timelock;
        // your implementation
    }

    /**
     * @notice Sends an HTTP request for AISentiment information
     * @param subscriptionId The ID of the Chainlink subscription
     * @return requestId The ID of the request
     */
    function sendRequest(uint64 subscriptionId, string[] calldata /*args*/ )
        external
        onlyOwner
        returns (bytes32 requestId)
    {
        FunctionsRequest.Request memory req;

        req.initializeRequestForInlineJavaScript(source);
        // Send the request and store the request ID
        oracle.lastRequestId = _sendRequest(req.encodeCBOR(), subscriptionId, gasLimit, donID);

        return oracle.lastRequestId;
    }

    /**
     * @notice Callback function for fulfilling a request
     * @param requestId The ID of the request to fulfill
     * @param response The HTTP response data
     * @param err Any errors from the Functions request
     */
    function fulfillRequest(bytes32 requestId, bytes memory response, bytes memory err) internal override {
        if (oracle.lastRequestId != requestId) {
            revert UnexpectedRequestID(requestId); // Check if request IDs match
        }
        // Update the contract's state variables with the response and any errors
        oracle.lastResponse = response;
        sentiment.value = uint256(bytes32(response));
        sentiment.timestamp = block.timestamp;
        oracle.lastError = err;

        // Emit an event to log the response
        emit Response(requestId, uint256(bytes32(response)), response, err);
    }

    function fulfillRequest2(bytes32 requestId, bytes memory response, bytes memory err) public {
        if (oracle.lastRequestId != requestId) {
            // Check if request IDs match
        }
        // Update the contract's state variables with the response and any errors
        oracle.lastResponse = response;
        sentiment.value = uint256(bytes32(response));
        sentiment.timestamp = block.timestamp;
        oracle.lastError = err;

        // Emit an event to log the response
        emit Response(requestId, uint256(bytes32(response)), response, err);
    }

    /**
     *
     * @param tokenId The token id.
     */
    function timelocks(uint256 tokenId) public view returns (uint256) {
        return _timelocks[tokenId];
    }

    /**
     * @dev Checks if the transfer of a specific token is allowed.
     * @param tokenId The ID of the token to check.
     * @return A boolean indicating whether the transfer is allowed or not.
     */
    function transferIsAllowed(uint256 tokenId) public view returns (bool) {
        return (_ownerOf(tokenId) == address(0) || _timelocks[tokenId] <= block.timestamp);
    }

    function _update(address to, uint256 tokenId, address auth) internal override(ERC721) returns (address) {
        if (!transferIsAllowed(tokenId)) {
            revert TokenLocked(tokenId);
        }
        return super._update(to, tokenId, auth);
    }

    // The following functions are overrides required by Solidity.
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

    function _setRouter(address _router) private {
        router = _router;
    }

    function _setDonID(bytes32 _donID) private {
        donID = _donID;
    }
}
