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
    AsideTokenManager public newManager;
    Observability public observability;
    IRoyaltyManager.Royalty public royalty =
        IRoyaltyManager.Royalty(address(0xa), 100);

    address public constant creator = address(0x1);
    address public constant minter = address(0x2);
    address public constant forwarder = address(0x3);
    address public constant attacker = address(0x4);
    address public constant recipient = address(0x5);
    uint256 public constant supply = 15;
    string public constant name = "Anna Ridler";
    string public constant symbol = "RDLR";
    string public constant contractURI =
        "ipfs://bafybeicy53j7e2er5kp8gfdsfg4ugecljgxxitnmmqztrdfst4i5z4pa76";
    string public constant baseURI =
        "ipfs://bafybeicy53j7e2er5kmft4rzj7ijr2cljgxxitnmmqztrdfst4i5z4pa74";

    function setUp() public {
        token = new ERC721GeneralSequence();
        observability = new Observability();
        manager = new AsideTokenManager();
        newManager = new AsideTokenManager();

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

    // #region ownership
    function test_owner() public {
        assertEq(manager.owner(), address(this));
    }

    function test_renounceOwnership() public {
        manager.renounceOwnership();
        assertEq(manager.owner(), address(0x0));
    }

    function test_RevertWhen_renounceOwnership_FromUnauthorized() public {
        vm.expectRevert("Ownable: caller is not the owner");
        vm.prank(attacker);
        manager.renounceOwnership();
    }

    function test_transferOwnership() public {
        manager.transferOwnership(address(0xf));
        assertEq(manager.owner(), address(0xf));
    }

    function test_RevertWhen_transferOwnership_FromUnauthorized() public {
        vm.expectRevert("Ownable: caller is not the owner");
        vm.prank(attacker);
        manager.transferOwnership(address(0xf));
    }

    // #endregion

    // #region canUpdateMetadata
    function test_setBaseURI() public {
        vm.prank(creator);
        token.setBaseURI("ipfs://newURI");
        assertEq(token.baseURI(), "ipfs://newURI");
    }

    function test_RevertWhen_setBaseURI_FromUnauthorized() public {
        vm.expectRevert(ERC721Base.Unauthorized.selector);
        token.setBaseURI("ipfs://newURI");
    }

    function test_setTokenURIs() public {
        uint256[] memory ids = new uint256[](1);
        string[] memory uris = new string[](1);
        ids[0] = 1;
        uris[0] = "ipfs://newURI";

        vm.prank(minter);
        token.mintOneToOneRecipient(recipient);

        vm.prank(creator);
        token.setTokenURIs(ids, uris);

        assertEq(token.tokenURI(1), "ipfs://newURI");
    }

    function test_RevertWhen_setTokenURIs_FromUnauthorized() public {
        uint256[] memory ids = new uint256[](1);
        string[] memory uris = new string[](1);
        ids[0] = 1;
        uris[0] = "ipfs://newURI";

        vm.prank(minter);
        token.mintOneToOneRecipient(recipient);

        vm.expectRevert(ERC721Base.Unauthorized.selector);
        token.setTokenURIs(ids, uris);
    }

    // #endregion

    // #region canSwap
    function test_setDefaultTokenManager() public {
        vm.prank(creator);
        token.setDefaultTokenManager(address(newManager));
        assertEq(token.tokenManager(1), address(newManager));
    }

    function test_RevertWhen_setDefaultTokenManager_FromUnauthorized() public {
        vm.expectRevert(ERC721Base.ManagerSwapBlocked.selector);
        token.setDefaultTokenManager(address(newManager));
    }

    function test_setGranularTokenManager() public {
        uint256[] memory ids = new uint256[](1);
        address[] memory tokenManagers = new address[](1);
        ids[0] = 1;
        tokenManagers[0] = address(newManager);

        vm.prank(creator);
        token.setGranularTokenManagers(ids, tokenManagers);
        assertEq(token.tokenManager(1), address(newManager));
    }

    function test_RevertWhen_setGranularTokenManager_FromUnauthorized() public {
        uint256[] memory ids = new uint256[](1);
        address[] memory tokenManagers = new address[](1);
        ids[0] = 1;
        tokenManagers[0] = address(newManager);

        vm.expectRevert(ERC721Base.ManagerSwapBlocked.selector);
        token.setGranularTokenManagers(ids, tokenManagers);
    }

    // #endregion

    // #region canRemoveItfself
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

    function test_removeGranularTokenManagers() public {
        uint256[] memory ids = new uint256[](1);
        address[] memory tokenManagers = new address[](1);

        ids[0] = 1;
        tokenManagers[0] = address(newManager);

        vm.prank(creator);
        token.setGranularTokenManagers(ids, tokenManagers);

        vm.prank(creator);
        token.removeGranularTokenManagers(ids);

        assertEq(token.tokenManager(1), address(manager));
    }

    function test_RevertWhen_removeGranularTokenManagers_FromUnauthorized()
        public
    {
        uint256[] memory ids = new uint256[](1);
        address[] memory tokenManagers = new address[](1);

        ids[0] = 1;
        tokenManagers[0] = address(newManager);

        vm.prank(creator);
        token.setGranularTokenManagers(ids, tokenManagers);

        vm.expectRevert(ERC721Base.ManagerRemoveBlocked.selector);
        token.removeGranularTokenManagers(ids);
    }

    // #endregion

    // #region lock / unlock
    function test_unlock() public {
        assertFalse(manager.isUnlocked(1));
        manager.unlock(1);
        assertTrue(manager.isUnlocked(1));
    }

    function test_RevertWhen_unlock_FromUnauthorized() public {
        vm.expectRevert("Ownable: caller is not the owner");
        vm.prank(attacker);
        manager.unlock(1);
    }

    function test_lock() public {
        assertFalse(manager.isUnlocked(1));
        manager.unlock(1);
        assertTrue(manager.isUnlocked(1));
        manager.lock(1);
        assertFalse(manager.isUnlocked(1));
    }

    function test_RevertWhen_lock_FromUnauthorized() public {
        vm.expectRevert("Ownable: caller is not the owner");
        vm.prank(attacker);
        manager.lock(1);
    }

    function test_transferFrom_WhenUnlocked() public {
        vm.prank(minter);
        token.mintOneToOneRecipient(recipient);
        assertEq(token.ownerOf(1), recipient);

        manager.unlock(1);

        vm.prank(recipient);
        token.transferFrom(recipient, address(0xf), 1);

        assertEq(token.ownerOf(1), address(0xf));
    }

    function test_RevertWhen_transferFrom_WhenLocked() public {
        vm.prank(minter);
        token.mintOneToOneRecipient(recipient);
        assertEq(token.ownerOf(1), recipient);

        vm.prank(recipient);
        vm.expectRevert(AsideTokenManager.TokenLocked.selector);
        token.transferFrom(recipient, address(0xf), 1);
    }

    function test_safeTransferFrom_WhenUnlocked() public {
        vm.prank(minter);
        token.mintOneToOneRecipient(recipient);
        assertEq(token.ownerOf(1), recipient);

        manager.unlock(1);

        vm.prank(recipient);
        token.safeTransferFrom(recipient, address(0xf), 1);

        assertEq(token.ownerOf(1), address(0xf));
    }

    function test_RevertWhen_safeTransferFrom_WhenLocked() public {
        vm.prank(minter);
        token.mintOneToOneRecipient(recipient);
        assertEq(token.ownerOf(1), recipient);

        vm.prank(recipient);
        vm.expectRevert(AsideTokenManager.TokenLocked.selector);
        token.safeTransferFrom(recipient, address(0xf), 1);
    }
}
