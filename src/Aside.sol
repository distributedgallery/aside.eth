// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {ERC721} from "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import {AccessControl} from "@openzeppelin/contracts/access/AccessControl.sol";
import {ERC721Burnable} from "@openzeppelin/contracts/token/ERC721/extensions/ERC721Burnable.sol";
import {ERC721URIStorage} from
  "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";

abstract contract Aside is ERC721, ERC721URIStorage, ERC721Burnable, AccessControl {
  error TokenLocked(uint256 tokenId);
  error TokenAlreadyUnlocked(uint256 tokenId);

  event Unlock(uint256 indexed tokenId);
  event EmergencyUnlock(bool unlocked);

  bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");
  uint256 public immutable TIMELOCK_DEADLINE;

  bool internal _eUnlocked = false; // emergency unlock

  mapping(uint256 => bool) internal _unlocks; // tokenId => isUnlocked

  /**
   * @notice Creates a new Aside contract.
   * @param admin The address to set as the DEFAULT_ADMIN of this contract.
   * @param minter The address to set as the MINTER of this contract.
   * @param timelock The duration of the timelock upon which all tokens are automatically unlocked.
   */
  constructor(
    string memory name_,
    string memory symbol_,
    address admin,
    address minter,
    uint256 timelock
  ) ERC721(name_, symbol_) {
    _grantRole(DEFAULT_ADMIN_ROLE, admin);
    _grantRole(MINTER_ROLE, minter);
    TIMELOCK_DEADLINE = block.timestamp + timelock;
  }

  // #region getters
  /**
   * @notice Checks whether all the tokens have been unlocked at once by emergency or not.
   * @return A boolean indicating whether all the tokens have been unlocked at once by emergency or
   * not.
   */
  function isEmergencyUnlocked() public view returns (bool) {
    return _eUnlocked;
  }

  /**
   * @notice Checks whether all the tokens are unlocked, either because of an emergency unlock or
   * because the lock deadline has been reached.
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

  // #region private / internal functionsπ
  function _areAllUnlocked() internal view returns (bool) {
    return block.timestamp >= TIMELOCK_DEADLINE || _eUnlocked;
  }

  function _isUnlocked(uint256 tokenId) internal view returns (bool) {
    return _unlocks[tokenId] || _areAllUnlocked();
  }

  function _update(address to, uint256 tokenId, address auth)
    internal
    override(ERC721)
    returns (address)
  {
    if (!_isUnlocked(tokenId) && _ownerOf(tokenId) != address(0)) revert TokenLocked(tokenId);
    return super._update(to, tokenId, auth);
  }
  // #endregion

  // #region required overrides
  function tokenURI(uint256 tokenId)
    public
    view
    override(ERC721, ERC721URIStorage)
    returns (string memory)
  {
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
  // #endregion
}
