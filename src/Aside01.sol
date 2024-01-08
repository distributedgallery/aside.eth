// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Burnable.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";

/// @custom:security-contact contact@distributedgallery.art
contract Aside0x01 is ERC721, ERC721URIStorage, ERC721Burnable, AccessControl {
    error TokenLocked(uint256 tokenId);

    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");

    mapping(uint256 => uint256) private _timelocks;

    constructor(address admin, address minter) ERC721("Aside0x01", "ASD") {
        _grantRole(DEFAULT_ADMIN_ROLE, admin);
        _grantRole(MINTER_ROLE, minter);
    }

    /**
     *
     * @param to The address to receive the token.
     * @param tokenId The token id.
     * @param timelock The timelock duration in seconds.
     * @param uri The token URI.
     */
    function mint(address to, uint256 tokenId, uint256 timelock, string memory uri) public onlyRole(MINTER_ROLE) {
        _safeMint(to, tokenId);
        _setTokenURI(tokenId, uri);
        _timelocks[tokenId] = block.timestamp + timelock;
        // your implementation
    }

    /**
     *
     * @param tokenId The token id.
     */
    function timelocks(uint256 tokenId) public view returns (uint256) {
        return _timelocks[tokenId];
    }

    /**
     * @dev Checks if the transfer of a specific token is allowed.
     * @param tokenId The ID of the token to check.
     * @return A boolean indicating whether the transfer is allowed or not.
     */
    function transferIsAllowed(uint256 tokenId) public view returns (bool) {
        return (_ownerOf(tokenId) == address(0) || _timelocks[tokenId] <= block.timestamp);
    }

    function _update(address to, uint256 tokenId, address auth) internal override(ERC721) returns (address) {
        if (!transferIsAllowed(tokenId)) {
            revert TokenLocked(tokenId);
        }
        return super._update(to, tokenId, auth);
    }

    // The following functions are overrides required by Solidity.
    function tokenURI(uint256 tokenId) public view override(ERC721, ERC721URIStorage) returns (string memory) {
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
}
