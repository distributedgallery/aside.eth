// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.25;

import {IAccessControl} from "@openzeppelin/contracts/access/AccessControl.sol";
import {IERC721Errors} from "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import {Test} from "forge-std/Test.sol";
import {AsideBase} from "../../../src/AsideBase.sol";

abstract contract AsideBaseTestHelper is Test {
    event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);
    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);
    event EmergencyUnlock();
    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);
    event Unlock(uint256 indexed tokenId);

    AsideBase public baseToken;
    address public constant admin = address(0xA);
    address public constant minter = address(0xB);
    address public constant owner = address(0x01);
    address public constant operator = address(0x02);
    address public constant approved = address(0x03);
    address public constant recipient = address(0x04);
    address public constant verse = address(0x5);
    uint256 public constant timelock = 365 days;
    uint256 public constant tokenId = 12;
    string public constant baseURI = "ipfs://bafybeicy53j7e2er5kmft4rzj7ijr2cljgxxitnmmqztrdfst4i5z4pa74/";
    string public constant tokenURI = "ipfs://bafybeicy53j7e2er5kmft4rzj7ijr2cljgxxitnmmqztrdfst4i5z4pa74/12";

    modifier mint() {
        _mint();
        _;
    }

    modifier unlock() {
        _reachTimelockDeadline();
        _;
    }

    function _tokenIds() public pure returns (uint256[] memory tokenIds) {
        tokenIds = new uint256[](1);
        tokenIds[0] = tokenId;
    }

    function _tokenIds(uint256 _tokenId) public pure returns (uint256[] memory tokenIds) {
        tokenIds = new uint256[](1);
        tokenIds[0] = _tokenId;
    }

    function _reachTimelockDeadline() internal {
        vm.warp(baseToken.TIMELOCK_DEADLINE());
    }

    function _mint() internal {
        vm.prank(minter);
        baseToken.mint(owner, tokenId);
    }

    function _mint(uint256 _tokenId) internal {
        vm.prank(minter);
        baseToken.mint(owner, _tokenId);
    }

    function _mintBatch() internal {
        address[] memory to = new address[](2);
        uint256[] memory tokenIds = new uint256[](2);
        to[0] = owner;
        to[1] = recipient;
        tokenIds[0] = tokenId;
        tokenIds[1] = tokenId + 1;
        vm.prank(minter);
        baseToken.mintBatch(to, tokenIds);
    }

    function _mint(address to) internal {
        vm.prank(minter);
        baseToken.mint(to, tokenId);
    }

    function _mintBatch(address _to) internal {
        address[] memory to = new address[](2);
        uint256[] memory tokenIds = new uint256[](2);
        to[0] = _to;
        to[1] = _to;
        tokenIds[0] = tokenId;
        tokenIds[1] = tokenId + 1;
        vm.prank(minter);
        baseToken.mintBatch(to, tokenIds);
    }
}
