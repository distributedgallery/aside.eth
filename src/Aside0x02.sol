// SPDX-License-Identifier: MIT
pragma solidity 0.8.25;

import {AsideBase} from "./AsideBase.sol";

contract Aside0x02 is AsideBase {
    error DisabledFunction();

    /**
     * @notice Creates a new Aside0x02 contract.
     * @param baseURI_ The base URI of the token.
     * @param admin_ The address to set as the DEFAULT_ADMIN of this contract.
     * @param minter_ The address to set as the MINTER of this contract.
     * @param verse_ The address of Verse's custodial wallet.
     * @param timelock_ The duration of the timelock upon which all tokens are automatically unlocked.
     */
    constructor(string memory baseURI_, address admin_, address minter_, address verse_, uint256 timelock_)
        AsideBase("Ray Marching the Moon: Full & New", "MOON", baseURI_, 130, admin_, minter_, verse_, timelock_)
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

    /**
     * @notice This function is disabled on this drop. Each token is automatically unlocked once the moon's phase it is tied to is reached.
     */
    function unlock(uint256[] calldata) external pure override {
        revert DisabledFunction();
    }

    // #region getter functions
    /**
     * @notice Returns the timestamp of the moon phase associated to token `tokenId`.
     * @dev `tokenId` must exist.
     * @return date The timestamp of the moon phase associated to token `tokenId`.
     */
    function moonOf(uint256 tokenId) public view returns (uint256) {
        _requireOwned(tokenId);

        return _moonOf(tokenId);
    }
    // #endregion

    // #region internal and private functions
    function _isUnlocked(uint256 tokenId) internal view override returns (bool) {
        return block.timestamp >= _moonOf(tokenId) || _areAllUnlocked();
    }

    function _moonOf(uint256 tokenId) private pure returns (uint256) {
        if (tokenId < 5) return 1_720_137_600;
        if (tokenId < 10) return 1_721_520_000;
        if (tokenId < 15) return 1_722_729_600;
        if (tokenId < 20) return 1_724_025_600;
        if (tokenId < 25) return 1_725_235_200;
        if (tokenId < 30) return 1_726_531_200;
        if (tokenId < 35) return 1_727_827_200;
        if (tokenId < 40) return 1_729_123_200;
        if (tokenId < 45) return 1_730_419_200;
        if (tokenId < 50) return 1_731_628_800;
        if (tokenId < 55) return 1_732_924_800;
        if (tokenId < 60) return 1_734_220_800;
        if (tokenId < 65) return 1_735_516_800;
        if (tokenId < 70) return 1_736_726_400;
        if (tokenId < 75) return 1_738_108_800;
        if (tokenId < 80) return 1_739_318_400;
        if (tokenId < 85) return 1_740_614_400;
        if (tokenId < 90) return 1_741_910_400;
        if (tokenId < 95) return 1_743_206_400;
        if (tokenId < 100) return 1_744_416_000;
        if (tokenId < 105) return 1_745_712_000;
        if (tokenId < 110) return 1_747_008_000;
        if (tokenId < 115) return 1_748_217_600;
        if (tokenId < 120) return 1_749_600_000;
        if (tokenId == 120 || tokenId == 121) return 1_736_726_400;
        if (tokenId == 125 || tokenId == 126) return 1_725_235_200;

        return 0;
    }
    // #endregion
}
