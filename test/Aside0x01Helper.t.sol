// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";
import {Test} from "forge-std/Test.sol";
import {Aside0x01, IERC721Errors, IAccessControl} from "../src/Aside0x01.sol";
import {AsideFunctionsRouter} from "./AsideFunctionsRouter.t.sol";
import {FunctionsRequest} from "../lib/chainlink/contracts/src/v0.8/functions/v1_0_0/libraries/FunctionsRequest.sol";

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

    // exclude this contract from coverage report
    function test() public {}
}

contract RevertingERC721Recipient is IERC721Receiver {
    function onERC721Received(address, address, uint256, bytes calldata) public virtual override returns (bytes4) {
        revert(string(abi.encodePacked(IERC721Receiver.onERC721Received.selector)));
    }

    // exclude this contract from coverage report
    function test() public {}
}

contract WrongReturnDataERC721Recipient is IERC721Receiver {
    function onERC721Received(address, address, uint256, bytes calldata) public virtual override returns (bytes4) {
        return 0xCAFEBEEF;
    }

    // exclude this contract from coverage report
    function test() public {}
}

contract NonERC721Recipient {
    // exclude this contract from coverage report
    function test() public {}
}

abstract contract TestHelper is Test {
    event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);
    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);
    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);
    event RequestReceived(
        uint64 subscriptionId, bytes data, uint16 dataVersion, uint32 callbackGasLimit, bytes32 donId
    );

    Aside0x01 token;
    AsideFunctionsRouter router;
    address admin = address(0xA);
    address minter = address(0xB);
    address owner = address(0x01);
    address operator = address(0x02);
    address approved = address(0x03);
    address recipient = address(0x04);
    uint256 tokenId = 1;
    uint256 sentiment = 60;
    uint64 subscriptionId = 1;
    bytes32 requestId = bytes32(uint256(0x01));
    bytes32 donId = 0x66756e2d657468657265756d2d7365706f6c69612d3100000000000000000000;
    string tokenURI = "ipfs://ipfs/Qm/1";
    string public source =
        "const response = await Functions.makeHttpRequest({url: 'https://aside-js.vercel.app/api/aisentiment', method: 'GET'});if (response.error) {throw Error('Request failed');}return Functions.encodeUint256(response.data.sentiment.toFixed(2)*100);";
    // Sepolia Chainlink Function parameters. See :
    // https://docs.chain.link/chainlink-functions/supported-networks
    // address router = 0xb83E47C2bC239B3bf370bc41e1459A34b41238D0;
    // bytes32 donID = 0x66756e2d657468657265756d2d7365706f6c69612d3100000000000000000000;

    modifier mint() {
        vm.prank(minter);
        token.mint(owner, tokenId, sentiment, tokenURI);
        _;
    }

    modifier unlock() {
        _unlock();
        _;
    }

    function setUp() public {
        router = new AsideFunctionsRouter();
        token = new Aside0x01(admin, minter, address(router), donId, subscriptionId);
    }

    function _unlock() internal {
        vm.warp(block.timestamp + 1000 days);
    }

    // exclude this contract from coverage report
    function test() public {}
}
