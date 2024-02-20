// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {IAccessControl} from "@openzeppelin/contracts/access/AccessControl.sol";
import {IERC721Errors} from "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import {Test} from "forge-std/Test.sol";
import {Aside} from "../../../src/Aside.sol";

abstract contract AsideTestHelper is Test {
  event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);
  event ApprovalForAll(address indexed owner, address indexed operator, bool approved);
  event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);
  event EmergencyUnlock(bool unlocked);

  address public constant admin = address(0xA);
  address public constant minter = address(0xB);
  address public constant owner = address(0x01);
  address public constant operator = address(0x02);
  address public constant approved = address(0x03);
  address public constant recipient = address(0x04);
  uint256 public constant tokenId = 1;
  uint256 public constant timelock = 365 days;
  string public constant tokenURI = "ipfs://ipfs/Qm/1";
}
