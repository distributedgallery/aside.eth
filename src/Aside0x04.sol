// SPDX-License-Identifier: MIT
pragma solidity 0.8.25;

import {AsideChainlink} from "./AsideChainlink.sol";

contract Aside0x04 is AsideChainlink {
    error DisabledFunction();
    error AlreadyUnlocked();
    error InvalidWeatherCode(uint256 code);

    event Unlock();

    uint256 public constant FOG_CODE = 741;
    bool private _unlocked = false;

    /**
     * @notice Creates a new Aside0x04 contract.
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
            "FELL-CLOUD",
            "FC",
            baseURI_,
            36,
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
        _aMint(0x4D3DfD28AA35869D52C5cE077Aa36E3944b48d1C, 30);
        _aMint(0x4CD7d2004a323133330D5A62aD7C734fAfD35236, 31);
        _aMint(0x3c7e48216C74D7818aB1Fd226e56C60C4D659bA6, 32);
        _aMint(0x3c7e48216C74D7818aB1Fd226e56C60C4D659bA6, 33);
        _aMint(0x3c7e48216C74D7818aB1Fd226e56C60C4D659bA6, 34);
        _aMint(0x3c7e48216C74D7818aB1Fd226e56C60C4D659bA6, 35);
    }

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
        if (uint256(bytes32(response)) == FOG_CODE) {
            _unlocked = true;
            emit Unlock();
        } else {
            revert InvalidWeatherCode(uint256(bytes32(response)));
        }
    }
    // #endregion

    // #region internal hook functions
    function _afterUpdate(bytes32, /*requestId*/ string[] memory /*args*/ ) internal virtual override {
        if (_unlocked) revert AlreadyUnlocked();
    }
    // #endregion

    // #region internal functions
    function _areAllUnlocked() internal view override returns (bool) {
        return _unlocked || super._areAllUnlocked();
    }
    // #endregion
}
