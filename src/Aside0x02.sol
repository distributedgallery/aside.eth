// SPDX-License-Identifier: MIT
pragma solidity 0.8.25;

import {AsideBase} from "./AsideBase.sol";

contract Aside0x02 is AsideBase {
    enum Moon {
        New,
        Full,
        Void
    }

    /**
     * @notice Creates a new Aside0x02 contract.
     * @param baseURI_ The base URI of the token.
     * @param admin_ The address to set as the DEFAULT_ADMIN of this contract.
     * @param minter_ The address to set as the MINTER of this contract.
     * @param verse_ The address of Verse's custodial wallet.
     * @param timelock_ The duration of the timelock upon which all tokens are automatically unlocked.
     */
    constructor(string memory baseURI_, address admin_, address minter_, address verse_, uint256 timelock_)
        AsideBase("Ray Marching the Moon", "MOON", baseURI_, 130, admin_, minter_, verse_, timelock_)
    {
        _aMint(0x4D3DfD28AA35869D52C5cE077Aa36E3944b48d1C, 120);
        _aMint(0x4CD7d2004a323133330D5A62aD7C734fAfD35236, 121);
        _aMint(0x3c7e48216C74D7818aB1Fd226e56C60C4D659bA6, 122);
        _aMint(0x3c7e48216C74D7818aB1Fd226e56C60C4D659bA6, 123);
        _aMint(0x3c7e48216C74D7818aB1Fd226e56C60C4D659bA6, 124);
        _aMint(0x4D3DfD28AA35869D52C5cE077Aa36E3944b48d1C, 125);
        _aMint(0x4CD7d2004a323133330D5A62aD7C734fAfD35236, 126);
        _aMint(0x3c7e48216C74D7818aB1Fd226e56C60C4D659bA6, 127);
        _aMint(0x3c7e48216C74D7818aB1Fd226e56C60C4D659bA6, 128);
        _aMint(0x3c7e48216C74D7818aB1Fd226e56C60C4D659bA6, 129);
    }

    // #region getter functions
    /**
     * @notice Returns the moon associated to token `tokenId`.
     * @dev `tokenId` must exist.
     * @return date The timestamp of the moon associated to token `tokenId`.
     * @return kind The kind of moon associated to token `tokenId`: either new (0), full (1) or void (3) [for never-locked AP tokens].
     */
    function moonOf(uint256 tokenId) public view returns (uint256 date, Moon kind) {
        _requireOwned(tokenId);

        return _moonOf(tokenId);
    }
    // #endregion

    // #region internal hook functions
    function _beforeUnlock(uint256[] memory tokenIds) internal override {
        super._beforeUnlock(tokenIds);

        uint256 length = tokenIds.length;
        for (uint256 i = 0; i < length; i++) {
            uint256 tokenId = tokenIds[i];
            (uint256 date,) = _moonOf(tokenId);
            if (date < block.timestamp) revert InvalidUnlock(tokenId);
        }
    }
    // #endregion

    // #region private functions
    function _moonOf(uint256 tokenId) private pure returns (uint256 date, Moon kind) {
        if (tokenId < 5) return (1_720_137_600, Moon.New);
        if (tokenId < 10) return (1_721_520_000, Moon.Full);
        if (tokenId < 15) return (1_722_729_600, Moon.New);
        if (tokenId < 20) return (1_724_025_600, Moon.Full);
        if (tokenId < 25) return (1_725_235_200, Moon.New);
        if (tokenId < 30) return (1_726_531_200, Moon.Full);
        if (tokenId < 35) return (1_727_827_200, Moon.New);
        if (tokenId < 40) return (1_729_123_200, Moon.Full);
        if (tokenId < 45) return (1_730_419_200, Moon.New);
        if (tokenId < 50) return (1_731_628_800, Moon.Full);
        if (tokenId < 55) return (1_732_924_800, Moon.New);
        if (tokenId < 60) return (1_734_220_800, Moon.Full);
        if (tokenId < 65) return (1_735_516_800, Moon.New);
        if (tokenId < 70) return (1_736_726_400, Moon.Full);
        if (tokenId < 75) return (1_738_108_800, Moon.New);
        if (tokenId < 80) return (1_739_318_400, Moon.Full);
        if (tokenId < 85) return (1_740_614_400, Moon.New);
        if (tokenId < 90) return (1_741_910_400, Moon.Full);
        if (tokenId < 95) return (1_743_206_400, Moon.New);
        if (tokenId < 100) return (1_744_416_000, Moon.Full);
        if (tokenId < 105) return (1_745_712_000, Moon.New);
        if (tokenId < 110) return (1_747_008_000, Moon.Full);
        if (tokenId < 115) return (1_748_217_600, Moon.New);
        if (tokenId < 120) return (1_749_600_000, Moon.Full);
        if (tokenId == 120 || tokenId == 121) return (1_736_726_400, Moon.Full);
        if (tokenId == 125 || tokenId == 126) return (1_725_235_200, Moon.New);

        return (0, Moon.Void);
    }
    // #endregion
}
