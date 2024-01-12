// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";
import {
    TestHelper,
    IAccessControl,
    IERC721Errors,
    ERC721Recipient,
    RevertingERC721Recipient,
    WrongReturnDataERC721Recipient,
    NonERC721Recipient
} from "./Aside0x01Helper.sol";

/**
 * Mints `tokenId`, transfers it to to and checks for to acceptance.
 *
 * Requirements:
 *  - `tokenId` must not exist.
 *  - If to refers to a smart contract, it must implement IERC721Receiver.onERC721Received, which is called upon a safe transfer.
 *
 * Emits a Transfer event.
 */
contract Mint is TestHelper {
    function test_MintToEOA() public mint {
        assertEq(token.balanceOf(owner), 1);
        assertEq(token.ownerOf(tokenId), owner);
        assertEq(token.timelocks(tokenId), block.timestamp + timelock);
        assertEq(token.tokenURI(tokenId), tokenURI);
    }

    function test_MintToERC721Recipient() public {
        ERC721Recipient to = new ERC721Recipient();

        vm.prank(minter);
        token.mint(address(to), tokenId, timelock, tokenURI);

        assertEq(token.balanceOf(address(to)), 1);
        assertEq(token.ownerOf(tokenId), address(to));
        assertEq(token.timelocks(tokenId), block.timestamp + timelock);
        assertEq(token.tokenURI(tokenId), tokenURI);

        assertEq(to.operator(), minter);
        assertEq(to.from(), address(0));
        assertEq(to.id(), tokenId);
        assertEq(to.data(), "");
    }

    function test_RevertWhen_MintToRevertingERC721Recipient() public {
        RevertingERC721Recipient to = new RevertingERC721Recipient();

        vm.expectRevert(abi.encodeWithSelector(IERC721Receiver.onERC721Received.selector));
        vm.prank(minter);
        token.mint(address(to), tokenId, timelock, tokenURI);
    }

    function test_RevertWhen_MintToNonERC721Recipient() public {
        NonERC721Recipient to = new NonERC721Recipient();

        vm.expectRevert(abi.encodeWithSelector(IERC721Errors.ERC721InvalidReceiver.selector, address(to)));
        vm.prank(minter);
        token.mint(address(to), tokenId, timelock, tokenURI);
    }

    function test_RevertWhen_MintToRevertingERC721RecipientWithWrongReturnData() public {
        WrongReturnDataERC721Recipient to = new WrongReturnDataERC721Recipient();

        vm.expectRevert(abi.encodeWithSelector(IERC721Errors.ERC721InvalidReceiver.selector, address(to)));
        vm.prank(minter);
        token.mint(address(to), tokenId, timelock, tokenURI);
    }

    function test_RevertWhen_MintFromUnauthorized() public {
        vm.expectRevert(
            abi.encodeWithSelector(
                IAccessControl.AccessControlUnauthorizedAccount.selector, address(this), token.MINTER_ROLE()
            )
        );
        token.mint(owner, tokenId, timelock, tokenURI);
    }

    function test_RevertWhen_MintToZeroAddress() public {
        vm.expectRevert(abi.encodeWithSelector(IERC721Errors.ERC721InvalidReceiver.selector, address(0)));
        vm.prank(minter);
        token.mint(address(0), tokenId, timelock, tokenURI);
    }

    function test_RevertWhen_DoubleMint() public mint unlock {
        vm.expectRevert(abi.encodeWithSelector(IERC721Errors.ERC721InvalidSender.selector, address(0)));
        vm.prank(minter);
        token.mint(owner, tokenId, timelock, tokenURI);
    }
}
