// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {IFunctionsRouter} from "../lib/chainlink/contracts/src/v0.8/functions/dev/1_0_0/interfaces/IFunctionsRouter.sol";
import {IFunctionsClient} from "../lib/chainlink/contracts/src/v0.8/functions/dev/1_0_0/interfaces/IFunctionsClient.sol";
import {FunctionsResponse} from
    "../lib/chainlink/contracts/src/v0.8/functions/dev/1_0_0/libraries/FunctionsResponse.sol";

// @title Chainlink Functions Router interface.

contract AsideFunctionsRouter is IFunctionsRouter {
    bytes32 public constant REQUEST_ID = bytes32(uint256(0x01));

    event RequestReceived(
        uint64 subscriptionId, bytes data, uint16 dataVersion, uint32 callbackGasLimit, bytes32 donId
    );

    function getAllowListId() external pure returns (bytes32) {
        return bytes32(0);
    }

    function setAllowListId(bytes32 /*allowListId*/ ) external pure {
        return;
    }

    function getAdminFee() external pure returns (uint72 adminFee) {
        adminFee = 0;
    }

    function sendRequest(
        uint64 subscriptionId,
        bytes calldata data,
        uint16 dataVersion,
        uint32 callbackGasLimit,
        bytes32 donId
    ) external returns (bytes32) {
        emit RequestReceived(subscriptionId, data, dataVersion, callbackGasLimit, donId);
        return REQUEST_ID;
    }

    function sendRequestToProposed(
        uint64 subscriptionId,
        bytes calldata data,
        uint16 dataVersion,
        uint32 callbackGasLimit,
        bytes32 donId
    ) external returns (bytes32) {
        emit RequestReceived(subscriptionId, data, dataVersion, callbackGasLimit, donId);
        return REQUEST_ID;
    }

    function fulfill(
        bytes memory, /*response*/
        bytes memory, /*err*/
        uint96, /*juelsPerGas*/
        uint96, /*costWithoutFulfillment*/
        address, /*transmitter*/
        FunctionsResponse.Commitment memory /*commitment*/
    ) external pure returns (FunctionsResponse.FulfillResult, uint96) {
        return (FunctionsResponse.FulfillResult.FULFILLED, 0);
    }

    function fulfillRequest(IFunctionsClient client, bytes32 requestId, bytes memory response, bytes memory err)
        external
    {
        client.handleOracleFulfillment(requestId, response, err);
    }

    function isValidCallbackGasLimit(uint64, /*subscriptionId*/ uint32 /*callbackGasLimit*/ ) external pure {
        return;
    }

    function getContractById(bytes32 /*id*/ ) external pure returns (address) {
        return address(0);
    }

    function getProposedContractById(bytes32 /*id*/ ) external pure returns (address) {
        return address(0);
    }

    function getProposedContractSet() external pure returns (bytes32[] memory, address[] memory) {
        bytes32[] memory ids;
        address[] memory to;
        return (ids, to);
    }

    function proposeContractsUpdate(bytes32[] memory, /*proposalSetIds*/ address[] memory /*proposalSetAddresses*/ )
        external
        pure
    {
        return;
    }

    function updateContracts() external pure {
        return;
    }

    function pause() external pure {
        return;
    }

    function unpause() external pure {
        return;
    }

    function test() public pure {
        return;
    }
}
