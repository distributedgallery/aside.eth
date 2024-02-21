// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import {AsideBaseTestHelper, IERC721Errors, IAccessControl} from "../../AsideBaseTestHelper.t.sol";
import {
    IERC721Receiver,
    ERC721Recipient,
    NonERC721Recipient,
    RevertingERC721Recipient,
    WrongReturnDataERC721Recipient
} from "./ERC721TestHelper.t.sol";

abstract contract Mint is AsideBaseTestHelper {
    function test_mint_ToEOA() public {
        vm.expectEmit(true, true, true, true);
        emit Transfer(address(0), owner, tokenId);
        _mint();

        assertEq(baseToken.ownerOf(tokenId), owner);
        assertEq(baseToken.balanceOf(owner), 1);
        assertEq(baseToken.tokenURI(tokenId), tokenURI);
    }

    function test_mint_ToERC721Recipient() public {
        ERC721Recipient to = new ERC721Recipient();

        vm.expectEmit(true, true, true, true);
        emit Transfer(address(0), address(to), tokenId);
        _mint(address(to));

        assertEq(baseToken.ownerOf(tokenId), address(to));
        assertEq(baseToken.balanceOf(address(to)), 1);
        assertEq(baseToken.tokenURI(tokenId), tokenURI);

        assertEq(to.operator(), minter);
        assertEq(to.from(), address(0));
        assertEq(to.id(), tokenId);
        assertEq(to.data(), "");
    }

    function test_RevertWhen_mint_ToNonERC721Recipient() public {
        address to = address(new NonERC721Recipient());
        vm.expectRevert(abi.encodeWithSelector(IERC721Errors.ERC721InvalidReceiver.selector, to));
        _mint(to);
    }

    function test_RevertWhen_mint_ToRevertingERC721Recipient() public {
        address to = address(new RevertingERC721Recipient());
        vm.expectRevert(abi.encodeWithSelector(IERC721Receiver.onERC721Received.selector));
        _mint(to);
    }

    function test_RevertWhen_mint_ToERC721RecipientWithWrongReturnData() public {
        address to = address(new WrongReturnDataERC721Recipient());

        vm.expectRevert(abi.encodeWithSelector(IERC721Errors.ERC721InvalidReceiver.selector, to));
        _mint(to);
    }

    function test_RevertWhen_mint_WhenTokenIsAlreadyMinted() public mint unlock {
        vm.expectRevert(abi.encodeWithSelector(IERC721Errors.ERC721InvalidSender.selector, address(0)));
        _mint();
    }

    function test_RevertWhen_mint_FromUnauthorized() public {
        vm.expectRevert(
            abi.encodeWithSelector(IAccessControl.AccessControlUnauthorizedAccount.selector, address(this), baseToken.MINTER_ROLE())
        );
        baseToken.mint(owner, tokenId, "payload");
    }

    function test_RevertWhen_mint_ToZeroAddress() public {
        vm.expectRevert(abi.encodeWithSelector(IERC721Errors.ERC721InvalidReceiver.selector, address(0)));
        _mint(address(0));
    }
}
