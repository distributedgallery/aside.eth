// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.10;

import {Test, console} from "forge-std/Test.sol";
import {ERC721Base, ERC721GeneralSequence} from "hl-evm-contracts/erc721/ERC721GeneralSequence.sol";
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

    // test ownership management

    function test_setBaseURI() public {
        vm.prank(creator);
        token.setBaseURI("ipfs://newURI");
        assertEq(token.baseURI(), "ipfs://newURI");
    }

    function test_RevertWhen_setBaseURI_FromUnauthorized() public {
        vm.expectRevert(ERC721Base.Unauthorized.selector);
        token.setBaseURI("ipfs://newURI");
    }

    function test_setDefaultTokenManager() public {
        AsideTokenManager m = new AsideTokenManager();

        vm.prank(creator);
        token.setDefaultTokenManager(address(m));
        assertEq(token.tokenManager(0), address(m));
    }

    function test_RevertWhen_setDefaultTokenManager_FromUnauthorized() public {
        AsideTokenManager m = new AsideTokenManager();
        vm.expectRevert(ERC721Base.ManagerSwapBlocked.selector);
        token.setDefaultTokenManager(address(m));
    }

    function test_setGranularTokenManager() public {
        AsideTokenManager m = new AsideTokenManager();
        uint256[] memory tokenIds = new uint256[](1);
        address[] memory tokenManagers = new address[](1);
        tokenIds[0] = 1;
        tokenManagers[0] = address(m);

        vm.prank(creator);
        token.setGranularTokenManagers(tokenIds, tokenManagers);
        assertEq(token.tokenManager(1), address(m));
    }

    function test_RevertWhen_setGranularTokenManager_FromUnauthorized() public {
        AsideTokenManager m = new AsideTokenManager();
        uint256[] memory tokenIds = new uint256[](1);
        address[] memory tokenManagers = new address[](1);
        tokenIds[0] = 1;
        tokenManagers[0] = address(m);
        vm.expectRevert(ERC721Base.ManagerSwapBlocked.selector);
        token.setGranularTokenManagers(tokenIds, tokenManagers);
    }

    function test_removeDefaultTokenManager() public {
        vm.prank(creator);
        token.removeDefaultTokenManager();
        assertEq(token.tokenManager(0), address(0));
    }

    function test_RevertWhen_removeDefaultTokenManager_FromUnauthorized()
        public
    {
        vm.expectRevert(ERC721Base.ManagerRemoveBlocked.selector);
        token.removeDefaultTokenManager();
    }

    function test_unlock() public {
        assertFalse(manager.isUnlocked(4));
        manager.unlock(4);
        assertTrue(manager.isUnlocked(4));
    }

    function test_lock() public {
        assertFalse(manager.isUnlocked(1));
        manager.unlock(4);
        assertTrue(manager.isUnlocked(4));
        manager.lock(4);
        assertFalse(manager.isUnlocked(4));
    }
}
