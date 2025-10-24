// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

import {ERC721} from "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import {ERC721Burnable} from "@openzeppelin/contracts/token/ERC721/extensions/ERC721Burnable.sol";
import {AccessControl} from "@openzeppelin/contracts/access/AccessControl.sol";

contract Aside0x08 is ERC721, ERC721Burnable, AccessControl {
    error Locked();
    error AlreadyUnlocked();
    error InvalidTokenId(uint256 tokenId);

    event BatchMetadataUpdate(uint256 _fromTokenId, uint256 _toTokenId); // https://eips.ethereum.org/EIPS/eip-4906
    event Unlock();

    uint256 public constant NB_OF_TOKENS = 81; // APs inlcluded
    string public BASE_URI_BEFORE_DEATH; // strings cannot be immutable
    string public BASE_URI_AFTER_DEATH; // strings cannot be immutable
    bool private _unlocked = false;

    /**
     * @notice Creates a new Aside0x08 contract.
     * @param baseURIBeforeDeath_ The base URI of the token before Lauren's death.
     * @param baseURIAfterDeath_ The base URI of the token After Lauren's death.
     * @param admin_ The address to set as the DEFAULT_ADMIN of this contract.
     */
    constructor(
        string memory baseURIBeforeDeath_,
        string memory baseURIAfterDeath_,
        address admin_
    ) ERC721("Good Bye", "GDBY") {
        _grantRole(DEFAULT_ADMIN_ROLE, admin_);
        BASE_URI_BEFORE_DEATH = baseURIBeforeDeath_;
        BASE_URI_AFTER_DEATH = baseURIAfterDeath_;
    }

    /**
     * @notice Mints `tokenId`, transfers it to `to` and checks for `to` acceptance.
     * @param to The address to receive the token to be minted.
     * @param tokenId The id of the token to be minted.
     */
    function mint(address to, uint256 tokenId) external {
        _aMint(to, tokenId);
    }

    // /**
    //  * @notice Mints `tokenIds`, transfers them to `to` and checks for `to` acceptance.
    //  * @param to The addresses to receive the tokens to be minted.
    //  * @param tokenIds The ids of the tokens to be minted.
    //  */
    // function mintBatch(
    //     address[] memory to,
    //     uint256[] memory tokenIds
    // ) external onlyRole(MINTER_ROLE) {
    //     uint256 length = to.length;
    //     if (length != tokenIds.length) revert InvalidParametersMatch();

    //     for (uint256 i = 0; i < length; i++) {
    //         _aMint(to[i], tokenIds[i]);
    //     }
    // }

    // #region admin-only functions
    /**
     * @notice Unlocks all the tokens at once.
     * @dev This function is meant to be used only if Lauren dies.
     */
    function unlock() external onlyRole(DEFAULT_ADMIN_ROLE) {
        if (_unlocked) revert AlreadyUnlocked();

        _unlocked = true;
        emit BatchMetadataUpdate(0, this.NB_OF_TOKENS() - 1);
        emit Unlock();
    }

    // #endregion

    // #region getter functions
    /**
     * @notice Checks whether all the tokens have been unlocked at once.
     * @return A boolean indicating whether all the tokens have been unlocked at once or not.
     */
    function isUnlocked() public view returns (bool) {
        return _unlocked;
    }

    // #endregion

    // #region internal functions
    function _baseURI() internal view virtual override returns (string memory) {
        if (_unlocked) {
            return BASE_URI_AFTER_DEATH;
        } else {
            return BASE_URI_BEFORE_DEATH;
        }
    }

    function _isUnlocked() internal view virtual returns (bool) {
        return _unlocked;
    }

    function _aMint(address to, uint256 tokenId) internal {
        _safeMint(to, tokenId);
        _afterMint(to, tokenId);
    }

    // #endregion

    // #region internal hook functions
    function _update(
        address to,
        uint256 tokenId,
        address auth
    ) internal override(ERC721) returns (address) {
        address owner = _ownerOf(tokenId);
        if (
            !_isUnlocked() &&
            owner != address(0) &&
            owner != address(0x3c7e48216C74D7818aB1Fd226e56C60C4D659bA6)
        ) {
            revert Locked();
        }
        return super._update(to, tokenId, auth);
    }

    function _afterMint(address, uint256 tokenId) internal virtual {
        if (tokenId >= NB_OF_TOKENS) revert InvalidTokenId(tokenId);
    }

    // #endregion

    // #region required overrides
    function supportsInterface(
        bytes4 interfaceId
    ) public view virtual override(ERC721, AccessControl) returns (bool) {
        return
            interfaceId == bytes4(0x49064906) ||
            super.supportsInterface(interfaceId);
    }
    // #endregion
}
