// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.25;

import {IAccessControl, IERC721Errors} from "../helpers/AsideBase/AsideBaseTestHelper.t.sol";
import {Aside0x08} from "../../src/Aside0x08.sol";
import {Test} from "forge-std/Test.sol";

abstract contract Aside0x08TestHelper is Test {
    event Approval(
        address indexed owner,
        address indexed approved,
        uint256 indexed tokenId
    );
    event ApprovalForAll(
        address indexed owner,
        address indexed operator,
        bool approved
    );
    event EmergencyUnlock();
    event Transfer(
        address indexed from,
        address indexed to,
        uint256 indexed tokenId
    );
    event Unlock(uint256 indexed tokenId);

    Aside0x08 public token;
    address public constant admin = address(0xA);
    address public constant minter = address(0xB);
    address public constant owner = address(0x01);
    address public constant operator = address(0x02);
    address public constant approved = address(0x03);
    address public constant recipient = address(0x04);
    address public constant unlocker =
        address(0x48C4f1D069724349bDDDcce259f9a5356c7Ce10E);
    uint256 public constant tokenId = 0;
    string public constant baseURI =
        "ipfs://bafybeicy53j7e2er5kmft4rzj7ijr2cljgxxitnmmqztrdfst4i5z4pa74/";
    string public constant tokenURI =
        "ipfs://bafybeicy53j7e2er5kmft4rzj7ijr2cljgxxitnmmqztrdfst4i5z4pa74/0";
    string public constant baseURI2 =
        "ipfs://bafybeicy53j7e2er5kmft4rzj7ijr2cljgxxitnmmqztrdfst4i5z4pa74/2/";
    string public constant tokenURI2 =
        "ipfs://bafybeicy53j7e2er5kmft4rzj7ijr2cljgxxitnmmqztrdfst4i5z4pa74/2/0";

    function setUp() public {
        token = new Aside0x08(baseURI, baseURI2, admin);
    }

    modifier mint() {
        _mint();
        _;
    }

    modifier unlock() {
        vm.prank(unlocker);
        token.unlock();
        _;
    }

    function _mint() internal {
        vm.warp(token.saleOpening());
        vm.prank(minter);
        token.mint(owner);
    }

    function _mint(address to) internal {
        vm.warp(token.saleOpening());
        vm.prank(minter);
        token.mint(to);
    }
}
