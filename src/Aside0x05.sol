// SPDX-License-Identifier: MIT
pragma solidity 0.8.25;

import {AsideChainlink} from "./AsideChainlink.sol";

contract Aside0x05 is AsideChainlink {
    error DisabledFunction();
    error AlreadyUnlocked();
    error InvalidElectionResult(uint256 result);

    event Unlock();

    bool private _harris = false;
    bool private _trump = false;

    /**
     * @notice Creates a new Aside0x05 contract.
     * @param baseURI_ The base URI of the token.
     * @param admin_ The address to set as the DEFAULT_ADMIN of this contract.
     * @param minter_ The address to set as the MINTER of this contract.
     * @param updater_ The address to set as the UPDATER of this contract.
     * @param verse_ The address of Verse's custodial wallet.
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
        address updater_,
        address verse_,
        uint256 timelock_,
        address router_,
        bytes32 donId_,
        uint64 subscriptionId_,
        uint32 callbackGasLimit_,
        string memory source_
    )
        AsideChainlink(
            "What Can Be",
            "WCB",
            baseURI_,
            100,
            admin_,
            minter_,
            updater_,
            verse_,
            timelock_,
            router_,
            donId_,
            subscriptionId_,
            callbackGasLimit_,
            source_
        )
    {
        _aMint(0x4D3DfD28AA35869D52C5cE077Aa36E3944b48d1C, 94);
        _aMint(0x4CD7d2004a323133330D5A62aD7C734fAfD35236, 95);
        _aMint(0x3c7e48216C74D7818aB1Fd226e56C60C4D659bA6, 96);
        _aMint(0x3c7e48216C74D7818aB1Fd226e56C60C4D659bA6, 97);
        _aMint(0x3c7e48216C74D7818aB1Fd226e56C60C4D659bA6, 98);
        _aMint(0x3c7e48216C74D7818aB1Fd226e56C60C4D659bA6, 99);
    }

    // #region getter functions
    /**
     * @notice Returns the result of the 2024 US election as stated by Wikidata oracles.
     * @return 0 if Harris, 1 if Trump, 3 otherwise.
     */
    function result() public view returns (uint256) {
        if (_harris) return 0;
        if (_trump) return 1;
        return 3;
    }
    // #endregion

    /**
     * @notice This function is disabled on this drop and replaced by `update()`.
     */
    function unlock(uint256[] calldata) external pure override {
        revert DisabledFunction();
    }

    // #region internal Chainlink functions
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
        uint256 _result = uint256(bytes32(response));

        if (_result == 0) {
            _harris = true;
            emit Unlock();
        } else if (_result == 1) {
            _trump = true;
            emit Unlock();
        } else {
            revert InvalidElectionResult(_result);
        }
    }
    // #endregion

    // #region internal functions
    function _isUnlocked(uint256 tokenId) internal view virtual override returns (bool) {
        if (tokenId <= 46 || tokenId == 94 || tokenId == 95 || tokenId == 96) return _harris || _areAllUnlocked();
        if (tokenId >= 47 && tokenId != 94 && tokenId != 95 && tokenId != 96) return _trump || _areAllUnlocked();

        return _areAllUnlocked();
    }
    // #endregion

    // #region internal hook functions
    function _afterUpdate(bytes32, /*requestId*/ string[] memory /*args*/ ) internal virtual override {
        if (_harris || _trump) revert AlreadyUnlocked();
    }
    // #endregion
}
