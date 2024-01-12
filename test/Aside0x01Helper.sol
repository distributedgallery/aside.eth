// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";
import {Test} from "forge-std/Test.sol";
import {Aside0x01, IERC721Errors, IAccessControl} from "../src/Aside0x01.sol";

contract ERC721Recipient is IERC721Receiver {
    address public operator;
    address public from;
    uint256 public id;
    bytes public data;

    function onERC721Received(address _operator, address _from, uint256 _id, bytes calldata _data)
        public
        virtual
        override
        returns (bytes4)
    {
        operator = _operator;
        from = _from;
        id = _id;
        data = _data;

        return IERC721Receiver.onERC721Received.selector;
    }
}

contract RevertingERC721Recipient is IERC721Receiver {
    function onERC721Received(address, address, uint256, bytes calldata) public virtual override returns (bytes4) {
        revert(string(abi.encodePacked(IERC721Receiver.onERC721Received.selector)));
    }
}

contract WrongReturnDataERC721Recipient is IERC721Receiver {
    function onERC721Received(address, address, uint256, bytes calldata) public virtual override returns (bytes4) {
        return 0xCAFEBEEF;
    }
}

contract NonERC721Recipient {}

abstract contract TestHelper is Test {
    event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);
    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);
    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);

    Aside0x01 public token;
    address admin = address(0xA);
    address minter = address(0xB);
    address owner = address(0x01);
    address operator = address(0x02);
    address approved = address(0x03);
    address recipient = address(0x04);
    uint256 tokenId = 1;
    uint256 timelock = 4324;
    string tokenURI = "ipfs://ipfs/Qm/1";

    modifier mint() {
        vm.prank(minter);
        token.mint(owner, tokenId, timelock, tokenURI);
        _;
    }

    modifier unlock() {
        vm.warp(block.timestamp + timelock + 1);
        _;
    }

    function setUp() public {
        token = new Aside0x01(admin, minter);
    }
}
