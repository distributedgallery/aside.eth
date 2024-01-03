// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console2} from "forge-std/Test.sol";
import {Aside0x01, IERC721Errors} from "../src/Aside01.sol";

contract Aside01Test is Test {
    Aside0x01 public token;
    address public immutable admin = address(0xA);
    address public immutable minter = address(0xB);
    address[3] public owners = [address(1), address(2), address(3)];

    event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);

    function setUp() public {
        // vm.prank(owner);
        token = new Aside0x01(admin, minter);
    }

    function test_Deploy() public {
        // assertEq(token.owner(), owner);
        assertEq(token.name(), "Aside0x01");
        assertEq(token.symbol(), "ASD");
    }

    // function testMint() public {
    //     vm.prank(minter);
    //     token.mint(owners[0], 1, 10, "ipfs://ipfs/Qm");

    //     assertEq(token.ownerOf(1), owners[0]);
    //     assertEq(token.tokenURI(1), "ipfs://ipfs/Qm");
    // }

    // function test_approve_FromOwner() public {
    //     vm.prank(minter);
    //     token.mint(owners[0], 1, 10, "ipfs://ipfs/Qm");

    //     vm.prank(owners[0]);

    //     vm.expectEmit(true, true, true, true);
    //     emit Approval(owners[0], owners[1], 1);

    //     token.approve(owners[1], 1);

    //     assertEq(token.getApproved(1), owners[1]);

    //     // check for events
    // }

    // function test_approve_FromApprovedOperatorForAll() public {
    //     vm.prank(minter);
    //     token.mint(owners[0], 1, 10, "ipfs://ipfs/Qm");

    //     vm.prank(owners[0]);
    //     token.setApprovalForAll(owners[1], true);

    //     vm.prank(owners[1]);
    //     token.approve(owners[2], 1);

    //     assertEq(token.getApproved(1), owners[2]);
    // }

    // function test_approve_RevertWhenFromNeitherOwnerNorApprovedOperatorForAll() public {
    //     vm.prank(minter);
    //     token.mint(owners[0], 1, 10, "ipfs://ipfs/Qm");

    //     vm.prank(owners[1]);
    //     vm.expectRevert(abi.encodeWithSelector(IERC721Errors.ERC721InvalidApprover.selector, owners[1]));
    //     token.approve(owners[2], 1);
    // }

    // function test_ApproveRevertsWhenNot() public {
    //     vm.prank(minter);
    //     token.mint(owners[0], 1, 10, "ipfs://ipfs/Qm");

    //     vm.prank(owners[0]);
    //     token.approve(owners[1], 1);

    //     assertEq(token.getApproved(1), owners[1]);
    // }

    // function test_Propose() public {
    //     vm.prank(address(0));
    //     governor.propose("This is proposal 0");
    //     vm.prank(address(1));
    //     governor.propose("This is proposal 1");
    //     (bool exists0, address author0, string memory description0, uint256 yeahs0, uint256 neahs0) =
    //         governor.getProposal(0);

    //     (bool exists1, address author1, string memory description1, uint256 yeahs1, uint256 neahs1) =
    //         governor.getProposal(1);

    //     assertEq(exists0, true);
    //     assertEq(author0, address(0));
    //     assertEq(description0, "This is proposal 0");
    //     assertEq(yeahs0, 0);
    //     assertEq(neahs0, 0);

    //     assertEq(exists1, true);
    //     assertEq(author1, address(1));
    //     assertEq(description1, "This is proposal 1");
    //     assertEq(yeahs1, 0);
    //     assertEq(neahs1, 0);
    // }

    // function test_Vote() public {
    //     governor.propose("This is proposal 0");
    //     governor.propose("This is proposal 1");

    //     vm.prank(address(0));
    //     governor.vote(0, true);
    //     vm.prank(address(1));
    //     governor.vote(0, false);
    //     vm.prank(address(1));
    //     governor.vote(1, true);

    //     (,,, uint256 yeahs0, uint256 neahs0) = governor.getProposal(0);
    //     (,,, uint256 yeahs1, uint256 neahs1) = governor.getProposal(1);

    //     assertEq(yeahs0, 1);
    //     assertEq(neahs0, 1);
    //     assertEq(yeahs1, 1);
    //     assertEq(neahs1, 0);

    //     assertEq(governor.hasVoted(0, address(0)), true);
    //     assertEq(governor.hasVoted(0, address(1)), true);
    //     assertEq(governor.hasVoted(1, address(0)), false);
    //     assertEq(governor.hasVoted(1, address(1)), true);
    // }

    // function test_RevertWhen_ProposalDoesNotExist() public {
    //     governor.propose("This is proposal 0");
    //     vm.expectRevert(abi.encodeWithSelector(UnknownProposal.selector, 1));
    //     vm.prank(address(0));
    //     governor.vote(1, true);
    // }

    // function test_RevertWhen_UserHasAlreadyVoted() public {
    //     governor.propose("This is proposal 0");
    //     vm.prank(address(0));
    //     governor.vote(0, true);
    //     vm.expectRevert(abi.encodeWithSelector(DoubleVote.selector, 0, address(0)));
    //     vm.prank(address(0));
    //     governor.vote(0, true);
    // }

    // function testFuzz_SetNumber(uint256 x) public {
    //     counter.setNumber(x);
    //     assertEq(counter.number(), x);
    // }
}
