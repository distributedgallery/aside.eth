// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.10;

import {Test, console} from "forge-std/Test.sol";
import {ERC721GeneralSequence} from "hl-evm-contracts/erc721/ERC721GeneralSequence.sol";
import {IRoyaltyManager} from "hl-evm-contracts/royaltyManager/interfaces/IRoyaltyManager.sol";
import {Observability} from "hl-evm-contracts/observability/Observability.sol";

import {AsideTokenManager} from "../src/AsideTokenManager.sol";

contract AsideTokenManagerTest is Test {
    ERC721GeneralSequence public token;
    AsideTokenManager public manager;
    Observability public observability;
    IRoyaltyManager.Royalty public royalty =
        IRoyaltyManager.Royalty(address(0x04), 100);

    address public constant creator = address(0x1);
    address public constant minter = address(0x2);
    address public constant forwarder = address(0x3);
    uint256 public constant supply = 15;
    string public constant name = "Anna Ridler";
    string public constant symbol = "RDLR";
    string public constant contractURI =
        "ipfs://bafybeicy53j7e2er5kp8gfdsfg4ugecljgxxitnmmqztrdfst4i5z4pa76/";
    string public constant baseURI =
        "ipfs://bafybeicy53j7e2er5kmft4rzj7ijr2cljgxxitnmmqztrdfst4i5z4pa74/";

    function setUp() public {
        observability = new Observability();
        token = new ERC721GeneralSequence();
        manager = new AsideTokenManager();

        token.initialize(
            creator,
            contractURI,
            royalty,
            address(manager),
            name,
            symbol,
            forwarder,
            minter,
            baseURI,
            supply,
            false,
            address(observability)
        );
    }

    function test_owner() public {
        assertEq(manager.owner(), address(this));
    }
}
