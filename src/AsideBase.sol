// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

import {ERC721} from "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import {ERC721Burnable} from "@openzeppelin/contracts/token/ERC721/extensions/ERC721Burnable.sol";
import {AccessControl} from "@openzeppelin/contracts/access/AccessControl.sol";

abstract contract AsideBase is ERC721, ERC721Burnable, AccessControl {
    error TokenLocked(uint256 tokenId);
    error TokenAlreadyUnlocked(uint256 tokenId);
    error InvalidTokenId(uint256 tokenId);
    error InvalidUnlock(uint256 tokenId);
    error InvalidParametersMatch();

    event Unlock(uint256 indexed tokenId);
    event EmergencyUnlock();

    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");
    uint256 public immutable NB_OF_TOKENS;
    address public immutable VERSE;
    uint256 public immutable TIMELOCK_DEADLINE;
    string public BASE_URI; // strings cannot be immutable
    bool private _eUnlocked = false; // emergency unlock
    mapping(uint256 => bool) private _unlocks; // tokenId => isUnlocked

    /**
     * @notice Creates a new AsideBase contract.
     * @param name_ The name of the token.
     * @param symbol_ The symbol of the token.
     * @param baseURI_ The base URI of the token.
     * @param nbOfTokens_ The number of tokens allowed to be minted.
     * @param admin_ The address to set as the DEFAULT_ADMIN of this contract.
     * @param minter_ The address to set as the MINTER of this contract.
     * @param verse_ The address of Verse's custodial wallet.
     * @param timelock_ The duration of the timelock upon which all tokens are automatically unlocked.
     */
    constructor(
        string memory name_,
        string memory symbol_,
        string memory baseURI_,
        uint256 nbOfTokens_,
        address admin_,
        address minter_,
        address verse_,
        uint256 timelock_
    ) ERC721(name_, symbol_) {
        _grantRole(DEFAULT_ADMIN_ROLE, admin_);
        _grantRole(MINTER_ROLE, minter_);
        BASE_URI = baseURI_;
        NB_OF_TOKENS = nbOfTokens_;
        VERSE = verse_;
        TIMELOCK_DEADLINE = block.timestamp + timelock_;
    }

    /**
     * @notice Mints `tokenId`, transfers it to `to` and checks for `to` acceptance.
     * @param to The address to receive the token to be minted.
     * @param tokenId The id of the token to be minted.
     */
    function mint(address to, uint256 tokenId) external onlyRole(MINTER_ROLE) {
        _aMint(to, tokenId);
    }

    /**
     * @notice Mints `tokenIds`, transfers them to `to` and checks for `to` acceptance.
     * @param to The addresses to receive the tokens to be minted.
     * @param tokenIds The ids of the tokens to be minted.
     */
    function mintBatch(address[] memory to, uint256[] memory tokenIds) external onlyRole(MINTER_ROLE) {
        uint256 length = to.length;
        if (length != tokenIds.length) revert InvalidParametersMatch();

        for (uint256 i = 0; i < length; i++) {
            _aMint(to[i], tokenIds[i]);
        }
    }

    /**
     * @notice Unlocks tokens `tokenIds`.
     * @dev Each tokenId in `tokenIds` must exist.
     * @dev Each tokenId in `tokenIds` must be locked.
     * @param tokenIds The ids of the tokens to unlock.
     */
    function unlock(uint256[] calldata tokenIds) external virtual {
        _beforeUnlock(tokenIds);
        uint256 length = tokenIds.length;
        for (uint256 i = 0; i < length; i++) {
            _unlock(tokenIds[i]);
        }
    }

    // #region admin-only functions
    /**
     * @notice Unlocks all the tokens at once.
     * @dev This function is only to be used in case of an emergency.
     */
    function eUnlock() external onlyRole(DEFAULT_ADMIN_ROLE) {
        _eUnlocked = true;

        emit EmergencyUnlock();
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
    function _baseURI() internal view override returns (string memory) {
        return BASE_URI;
    }

    function _areAllUnlocked() internal view virtual returns (bool) {
        return block.timestamp >= TIMELOCK_DEADLINE || _eUnlocked;
    }

    function _isUnlocked(uint256 tokenId) internal view virtual returns (bool) {
        return _unlocks[tokenId] || _areAllUnlocked();
    }

    function _requireLocked(uint256 tokenId) internal view {
        _requireOwned(tokenId);
        if (_isUnlocked(tokenId)) revert TokenAlreadyUnlocked(tokenId);
    }

    function _aMint(address to, uint256 tokenId) internal {
        _safeMint(to, tokenId);
        _afterMint(to, tokenId);
    }

    function _unlock(uint256 tokenId) internal {
        _unlocks[tokenId] = true;
        emit Unlock(tokenId);
    }
    // #endregion

    // #region internal hook functions
    function _update(address to, uint256 tokenId, address auth) internal override(ERC721) returns (address) {
        address owner = _ownerOf(tokenId);
        if (!_isUnlocked(tokenId) && owner != address(0) && owner != VERSE) revert TokenLocked(tokenId);
        if (to == address(0)) _unlocks[tokenId] = false;
        return super._update(to, tokenId, auth);
    }

    function _afterMint(address, uint256 tokenId) internal virtual {
        if (tokenId >= NB_OF_TOKENS) revert InvalidTokenId(tokenId);
    }

    function _beforeUnlock(uint256[] memory tokenIds) internal virtual {
        uint256 length = tokenIds.length;
        for (uint256 i = 0; i < length; i++) {
            _requireLocked(tokenIds[i]);
        }
    }
    // #endregion

    // #region required overrides
    function supportsInterface(bytes4 interfaceId) public view override(ERC721, AccessControl) returns (bool) {
        return super.supportsInterface(interfaceId);
    }
    // #endregion
}
