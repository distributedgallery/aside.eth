// SPDX-License-Identifier: MIT
pragma solidity 0.8.25;

import {AsideBase} from "./AsideBase.sol";
import {AggregatorV3Interface} from "chainlink/src/v0.8/shared/interfaces/AggregatorV3Interface.sol";

contract Aside0x03 is AsideBase {
    error DisabledFunction();
    error AlreadyUnlocked();
    error InvalidPrice();

    event Unlock();

    int256 public constant PRICE_LIMIT = 1_000_000_000_000;
    AggregatorV3Interface public feed;
    bool private _unlocked = false;

    /**
     * @notice Creates a new Aside0x03 contract.
     * @param baseURI_ The base URI of the token.
     * @param admin_ The address to set as the DEFAULT_ADMIN of this contract.
     * @param minter_ The address to set as the MINTER of this contract.
     * @param verse_ The address of Verse's custodial wallet.
     * @param timelock_ The duration of the timelock upon which all tokens are automatically unlocked.
     * @param feed_ The address of Chainlink's ETH / USD price feed.
     */
    constructor(string memory baseURI_, address admin_, address minter_, address verse_, uint256 timelock_, address feed_)
        AsideBase("10K Drop", "10K", baseURI_, 210, admin_, minter_, verse_, timelock_)
    {
        feed = AggregatorV3Interface(feed_);

        _aMint(0x4D3DfD28AA35869D52C5cE077Aa36E3944b48d1C, 200);
        _aMint(0x4CD7d2004a323133330D5A62aD7C734fAfD35236, 201);
        _aMint(0x3c7e48216C74D7818aB1Fd226e56C60C4D659bA6, 202);
        _aMint(0x3c7e48216C74D7818aB1Fd226e56C60C4D659bA6, 203);
        _aMint(0x3c7e48216C74D7818aB1Fd226e56C60C4D659bA6, 204);
        _aMint(0x3c7e48216C74D7818aB1Fd226e56C60C4D659bA6, 205);
        _aMint(0x3c7e48216C74D7818aB1Fd226e56C60C4D659bA6, 206);
        _aMint(0x3c7e48216C74D7818aB1Fd226e56C60C4D659bA6, 207);
        _aMint(0x3c7e48216C74D7818aB1Fd226e56C60C4D659bA6, 208);
        _aMint(0x3c7e48216C74D7818aB1Fd226e56C60C4D659bA6, 209);
    }

    /**
     * @notice This function is disabled on this drop and replaced by `unlock()`.
     */
    function unlock(uint256[] calldata) external pure override {
        revert DisabledFunction();
    }

    /**
     * @notice Unlocks all tokens at once if ETH / USD price is above `PRICE_LIMIT`, reverts otherwise.
     */
    function unlock() external {
        if (_unlocked) revert AlreadyUnlocked();

        (, int256 answer,,,) = feed.latestRoundData();
        if (answer >= PRICE_LIMIT) {
            _unlocked = true;
            emit Unlock();
        } else {
            revert InvalidPrice();
        }
    }

    // #region admin-only functions
    /**
     * @notice Update the address of Chainlink's ETH / USD price feed.
     * @param feed_ The address of Chainlink's ETH / USD new price feed.
     */
    function updateFeed(address feed_) external onlyRole(DEFAULT_ADMIN_ROLE) {
        feed = AggregatorV3Interface(feed_);
    }
    // #endregion

    // #region getter functions
    function price() public view returns (int256) {
        (, int256 answer,,,) = feed.latestRoundData();

        return answer;
    }
    // #endregion

    // #region internal functions
    function _areAllUnlocked() internal view override returns (bool) {
        return _unlocked || super._areAllUnlocked();
    }

    function _afterMint(address receiver, uint256 tokenId) internal override {
        if (tokenId > 201) _unlock(tokenId);
        super._afterMint(receiver, tokenId);
    }
    // #endregion
}
