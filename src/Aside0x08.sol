// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

import {ERC721} from "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import {ERC721Burnable} from "@openzeppelin/contracts/token/ERC721/extensions/ERC721Burnable.sol";
import {AccessControl} from "@openzeppelin/contracts/access/AccessControl.sol";
import {ReentrancyGuard} from "@openzeppelin/contracts/utils/ReentrancyGuard.sol";

contract Aside0x08 is ERC721, ERC721Burnable, AccessControl, ReentrancyGuard {
    error Locked();
    error AlreadyUnlocked();
    error NoTokenLeft();
    error InvalidPrice();
    error SaleNotOpened();

    event BatchMetadataUpdate(uint256 _fromTokenId, uint256 _toTokenId); // https://eips.ethereum.org/EIPS/eip-4906
    event Unlock();

    bytes32 public constant UNLOCKER_ROLE = keccak256("UNLOCKER_ROLE");
    uint256 public constant NB_OF_TOKENS = 65; // APs NOT included
    uint256 public constant PRICE = 0.1 ether;
    string public BASE_URI_BEFORE_DEATH; // strings cannot be immutable
    string public BASE_URI_AFTER_DEATH; // strings cannot be immutable

    uint256 private _count;
    uint256 private _saleOpening = 1761955200;
    bool private _isSalePaused = false;
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
        _grantRole(UNLOCKER_ROLE, 0x48C4f1D069724349bDDDcce259f9a5356c7Ce10E);

        BASE_URI_BEFORE_DEATH = baseURIBeforeDeath_;
        BASE_URI_AFTER_DEATH = baseURIAfterDeath_;

        // mint APs
        for (uint i = 65; i < 81; i++) {
            _safeMint(0x3c7e48216C74D7818aB1Fd226e56C60C4D659bA6, i);
        }
    }

    /**
     * @notice Mints `_count`, transfers it to `to` and checks for `to` acceptance.
     * @param to The address to receive the token to be minted.
     */
    function mint(address to) external payable nonReentrant {
        if (!_isSaleOpened()) revert SaleNotOpened();
        if (_count >= NB_OF_TOKENS) revert NoTokenLeft();
        if (msg.value != PRICE) revert InvalidPrice();

        _safeMint(to, _count++);
    }

    //////////////////////////////////////////////////////////
    // Protected functions
    //////////////////////////////////////////////////////////
    /**
     * @notice Unlocks all the tokens at once.
     * @dev This function is meant to be used only if Lauren dies.
     */
    function unlock() external onlyRole(UNLOCKER_ROLE) {
        if (_unlocked) revert AlreadyUnlocked();

        _unlocked = true;
        emit BatchMetadataUpdate(0, type(uint256).max);
        emit Unlock();
    }

    /**
     * @notice Pauses sale.
     */
    function pauseSale() external onlyRole(DEFAULT_ADMIN_ROLE) {
        _isSalePaused = true;
    }

    /**
     * @notice Unpauses sale.
     */
    function unpauseSale() external onlyRole(DEFAULT_ADMIN_ROLE) {
        _isSalePaused = false;
    }

    /**
     * @notice Sets when the sale opens.
     * @param from The timestamp of the sale's opening.
     */
    function setSaleOpening(
        uint256 from
    ) external onlyRole(DEFAULT_ADMIN_ROLE) {
        _saleOpening = from;
    }

    /**
     * @notice Withdraws balance to `_to` address.
     * @param _to The address to withdraw the balance to.
     */
    function withdraw(
        address payable _to
    ) external onlyRole(DEFAULT_ADMIN_ROLE) {
        require(_to != address(0));
        (bool success, ) = _to.call{value: address(this).balance}("");
        require(success);
    }

    //////////////////////////////////////////////////////////
    // Getter functions
    //////////////////////////////////////////////////////////
    /**
     * @notice Checks whether all the tokens have been unlocked or not.
     * @return A boolean indicating whether all the tokens have been unlocked or not.
     */
    function isUnlocked() public view returns (bool) {
        return _unlocked;
    }

    /**
     * @notice Returns a timestamp of the sale opening.
     * @return A timestamp of the sale opening.
     */
    function saleOpening() public view returns (uint256) {
        return _saleOpening;
    }

    /**
     * @notice Checks whether the sale is paused or not.
     * @return A boolean indicating whether the sale is paused or not.
     */
    function isSalePaused() public view returns (bool) {
        return _isSalePaused;
    }

    /**
     * @notice Checks whether the sale is opened or not.
     * @return A boolean indicating whether the sale is opened or not.
     */
    function isSaleOpened() public view returns (bool) {
        return _isSaleOpened();
    }

    /**
     * @notice Returns the number of minted tokens [excluding APs].
     * @return The number of minted tokens [excluding APs].
     */
    function editionCount() public view returns (uint256) {
        return _count;
    }

    //////////////////////////////////////////////////////////
    // Internal functions
    //////////////////////////////////////////////////////////
    function _baseURI() internal view override returns (string memory) {
        if (_unlocked) {
            return BASE_URI_AFTER_DEATH;
        } else {
            return BASE_URI_BEFORE_DEATH;
        }
    }

    function _isSaleOpened() internal view returns (bool) {
        return !_isSalePaused && block.timestamp >= _saleOpening;
    }

    function _isUnlocked() internal view returns (bool) {
        return _unlocked;
    }

    //////////////////////////////////////////////////////////
    // Internal hook functions
    //////////////////////////////////////////////////////////
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

    //////////////////////////////////////////////////////////
    // Override functions
    //////////////////////////////////////////////////////////
    function supportsInterface(
        bytes4 interfaceId
    ) public view override(ERC721, AccessControl) returns (bool) {
        return
            interfaceId == bytes4(0x49064906) ||
            super.supportsInterface(interfaceId);
    }
}
