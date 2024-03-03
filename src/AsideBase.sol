// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {ERC721} from "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import {AccessControl} from "@openzeppelin/contracts/access/AccessControl.sol";

abstract contract AsideBase is ERC721, AccessControl {
    error TokenLocked(uint256 tokenId);
    error TokenAlreadyUnlocked(uint256 tokenId);
    error InvalidPayload(string payload);

    event Unlock(uint256 indexed tokenId);
    event EmergencyUnlock(bool unlocked);

    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");
    bytes32 public constant UNLOCKER_ROLE = keccak256("UNLOCKER_ROLE");
    uint256 public immutable TIMELOCK_DEADLINE;
    string public BASE_URI;
    bool private _eUnlocked = false; // emergency unlock
    mapping(uint256 => bool) private _unlocks; // tokenId => isUnlocked

    modifier isLocked(uint256 tokenId) {
        _ensureLocked(tokenId);
        _;
    }

    /**
     * @notice Creates a new AsideBase contract.
     * @param name_ The name of the token.
     * @param symbol_ The symbol of the token.
     * @param baseURI_ The base URI of the token.
     * @param admin_ The address to set as the DEFAULT_ADMIN of this contract.
     * @param minter_ The address to set as the MINTER of this contract.
     * @param unlocker_ The address to set as the UNLOCKER of this contract.
     * @param timelock_ The duration of the timelock upon which all tokens are automatically unlocked.
     */
    constructor(
        string memory name_,
        string memory symbol_,
        string memory baseURI_,
        address admin_,
        address minter_,
        address unlocker_,
        uint256 timelock_
    ) ERC721(name_, symbol_) {
        _grantRole(DEFAULT_ADMIN_ROLE, admin_);
        _grantRole(MINTER_ROLE, minter_);
        _grantRole(UNLOCKER_ROLE, unlocker_);
        TIMELOCK_DEADLINE = block.timestamp + timelock_;
        BASE_URI = baseURI_;
    }

    /**
     * @notice Mints `tokenId`, transfers it to `to` and checks for `to` acceptance.
     * @param to The address to receive the token to be minted.
     * @param tokenId The id of the token to be minted.
     * @param payload The payload to be used for the token to be minted.
     */
    function mint(address to, uint256 tokenId, string calldata payload) external virtual;

    /**
     * @notice Unlock token `tokenId`.
     * @dev `tokenId` must exist.
     * @dev `tokenId` must be locked.
     * @param tokenId The id of the token to unlock.
     */
    function unlock(uint256 tokenId) external virtual;

    // function unlock(uint256 tokenId) external payable virtual;

    // #region admin-only functions
    /**
     * @notice Unlocks all the tokens at once.
     * @dev This function is only to be used in case of an emergency.
     */
    function eUnlock() external onlyRole(DEFAULT_ADMIN_ROLE) {
        _eUnlocked = true;

        emit EmergencyUnlock(true);
    }

    /**
     * @notice Cancels any emergency unlock.
     * @dev This function is only to be used in case an emergency unlock has been triggered by
     * mistake.
     */
    function eRelock() external onlyRole(DEFAULT_ADMIN_ROLE) {
        _eUnlocked = false;

        emit EmergencyUnlock(false);
    }
    // #endregion

    // #region getter functions
    /**
     * @notice Checks whether all the tokens have been unlocked at once in an emergency or not.
     * @return A boolean indicating whether all the tokens have been unlocked at once in an emergency or
     * not.
     */
    function isEUnlocked() public view returns (bool) {
        return _eUnlocked;
    }

    /**
     * @notice Checks whether all the tokens are unlocked, either because of an emergency unlock or
     * because the timelock deadline has been reached.
     * @return A boolean indicating whether all the tokens are unlocked or not.
     */
    function areAllUnlocked() public view returns (bool) {
        return _areAllUnlocked();
    }

    /**
     * @notice Checks whether token `tokenId` is unlocked or not.
     * @dev `tokenId` must exist.
     * @param tokenId The id of the token to check whether it is unlocked or not.
     * @return A boolean indicating whether token `tokenId` is unlocked or not.
     */
    function isUnlocked(uint256 tokenId) public view returns (bool) {
        _requireOwned(tokenId);

        return _isUnlocked(tokenId);
    }
    // #endregion

    // #region internal functions
    function _ensureLocked(uint256 tokenId) internal view {
        _requireOwned(tokenId);
        if (_isUnlocked(tokenId)) revert TokenAlreadyUnlocked(tokenId);
    }

    function _baseURI() internal view override returns (string memory) {
        return BASE_URI;
    }

    function _areAllUnlocked() internal view returns (bool) {
        return block.timestamp >= TIMELOCK_DEADLINE || _eUnlocked;
    }

    function _isUnlocked(uint256 tokenId) internal view returns (bool) {
        return _unlocks[tokenId] || _areAllUnlocked();
    }

    function _unlock(uint256 tokenId) internal {
        _unlocks[tokenId] = true;

        emit Unlock(tokenId);
    }

    function _update(address to, uint256 tokenId, address auth) internal override(ERC721) returns (address) {
        if (!_isUnlocked(tokenId) && _ownerOf(tokenId) != address(0)) revert TokenLocked(tokenId);
        return super._update(to, tokenId, auth);
    }
    // #endregion

    // #region required overrides
    function supportsInterface(bytes4 interfaceId) public view override(ERC721, AccessControl) returns (bool) {
        return super.supportsInterface(interfaceId);
    }
    // #endregion
}
