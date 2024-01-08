// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";
import {TestHelper} from "./Aside0x01Helper.sol";
import {Aside0x01, IERC721Errors} from "../src/Aside01.sol";
import "forge-std/console.sol";

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

contract Transfer is TestHelper {
    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);

    function test_mint() public {
        vm.prank(minter);
        token.mint(owner, tokenId, timelock, tokenURI);

        assertEq(token.balanceOf(owner), 1);
        assertEq(token.ownerOf(tokenId), owner);
    }
}
