// SPDX-License-Identifier: MIT
pragma solidity 0.8.25;

import {AsideBase} from "./AsideBase.sol";

contract Aside0x08 is AsideBase {
    error DisabledFunction();

    event BatchMetadataUpdate(uint256 _fromTokenId, uint256 _toTokenId);

    string public BASE_URI_AFTER_DEATH; // strings cannot be immutable

    /**
     * @notice Creates a new Aside0x02 contract.
     * @param baseURI1_ The base URI of the token before Lauren's death.
     * @param baseURI2_ The base URI of the token after Lauren's death.
     * @param admin_ The address to set as the DEFAULT_ADMIN of this contract.
     * @param minter_ The address to set as the MINTER of this contract.
     * @param verse_ The address of Verse's custodial wallet.
     * @param timelock_ The duration of the timelock upon which all tokens are automatically unlocked.
     */
    constructor(
        string memory baseURI1_,
        string memory baseURI2_,
        address admin_,
        address minter_,
        address verse_,
        uint256 timelock_
    )
        AsideBase(
            "Goodbye",
            "GDBY",
            baseURI1_,
            81,
            admin_,
            minter_,
            verse_,
            timelock_
        )
    {
        BASE_URI_AFTER_DEATH = baseURI2_;
        // _aMint(0x4D3DfD28AA35869D52C5cE077Aa36E3944b48d1C, 120);
    }

    /**
     * @notice This function is disabled on this drop. Each token is automatically unlocked once the moon's phase it is tied to is reached.
     */
    function unlock(uint256[] calldata) external pure override {
        revert DisabledFunction();
    }

    function _eUnlock() internal override {
        emit BatchMetadataUpdate(0, this.NB_OF_TOKENS());
        super._eUnlock();
    }

    function _baseURI() internal view override returns (string memory) {
        if (_areAllUnlocked()) {
            return BASE_URI_AFTER_DEATH;
        } else {
            return BASE_URI;
        }
    }

    function supportsInterface(
        bytes4 interfaceId
    ) public view override(AsideBase) returns (bool) {
        return
            interfaceId == bytes4(0x49064906) ||
            super.supportsInterface(interfaceId);
    }

    // #endregion
}
