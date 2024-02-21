// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import {IAccessControl} from "@openzeppelin/contracts/access/AccessControl.sol";
import {IERC721Errors} from "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import {Test} from "forge-std/Test.sol";
import {AsideBase} from "../../../src/AsideBase.sol";

abstract contract AsideBaseTestHelper is Test {
    event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);
    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);
    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);
    event EmergencyUnlock(bool unlocked);

    AsideBase public baseToken;
    address public constant admin = address(0xA);
    address public constant minter = address(0xB);
    address public constant owner = address(0x01);
    address public constant operator = address(0x02);
    address public constant approved = address(0x03);
    address public constant recipient = address(0x04);
    uint256 public constant timelock = 365 days;
    uint256 public constant tokenId = 1;
    string public constant tokenURI = "ipfs://ipfs/Qm/1";

    modifier unlock() {
        _reachTimelockDeadline();
        _;
    }

    modifier mint() {
        _mint();
        _;
    }

    function _reachTimelockDeadline() internal {
        vm.warp(baseToken.TIMELOCK_DEADLINE());
    }

    function _mint() internal virtual {}
}
