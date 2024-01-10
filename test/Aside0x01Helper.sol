// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console2} from "forge-std/Test.sol";
import {Aside0x01, IERC721Errors, IAccessControl} from "../src/Aside01.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";

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
    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);
    event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);
    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);

    Aside0x01 public token;
    address[3] public owners = [address(1), address(2), address(3)];
    address owner = address(9);
    uint256 tokenId = 12;
    address operator = address(73);
    address approved = address(99);
    address public recipient = address(10);
    uint256[3] public tokens = [0, 1, 2];
    uint256[3] public timelocks = [154, 48239, 124443];
    uint256 timelock = 4324;
    string[3] public tokenURIs = ["ipfs://ipfs/Qm/1", "ipfs://ipfs/Qm/2", "ipfs://ipfs/Qm/3"];
    string tokenURI = "ipfs://ipfs/Qm/1";
    address public constant admin = address(0xA);
    address public constant minter = address(0xB);

    modifier mint() {
        vm.prank(minter);
        token.mint(owner, tokenId, timelock, tokenURI);
        _;
    }

    modifier unlock() {
        _unlock();
        _;
    }

    function setUp() public {
        token = new Aside0x01(admin, minter);
        vm.prank(minter);
        token.mint(owners[0], 0, timelocks[0], tokenURIs[0]);
        vm.prank(minter);
        token.mint(owners[1], 1, timelocks[1], tokenURIs[1]);
        vm.prank(minter);
        token.mint(owners[2], 2, timelocks[2], tokenURIs[2]);
        // vm.prank(minter);
        // token.mint(owner, tokenId, timelock, tokenURI);
    }

    function moveToUnlock() public {
        vm.warp(block.timestamp + timelocks[0] + timelocks[1] + timelocks[2] + 1);
    }

    function _unlock() internal {
        vm.warp(block.timestamp + timelock + timelocks[0] + timelocks[1] + timelocks[2] + 1);
    }
}
