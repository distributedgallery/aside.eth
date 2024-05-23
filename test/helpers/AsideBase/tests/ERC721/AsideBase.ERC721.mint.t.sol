// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.25;

import {AsideBase, AsideBaseTestHelper, IAccessControl, IERC721Errors} from "../../AsideBaseTestHelper.t.sol";
import {
    IERC721Receiver,
    ERC721Recipient,
    NonERC721Recipient,
    RevertingERC721Recipient,
    WrongReturnDataERC721Recipient
} from "./ERC721TestHelper.t.sol";

abstract contract Mint is AsideBaseTestHelper {
    function test_mint_ToEOA() public {
        vm.expectEmit(address(baseToken));
        emit Transfer(address(0), owner, tokenId);
        _mint();

        assertEq(baseToken.ownerOf(tokenId), owner);
        assertEq(baseToken.balanceOf(owner), 1);
        assertEq(baseToken.tokenURI(tokenId), tokenURI);
    }

    function test_mint_ToERC721Recipient() public {
        ERC721Recipient to = new ERC721Recipient();
        vm.expectEmit(address(baseToken));
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

    function test_RevertWhen_mint_ToWrongReturnDataERC721Recipient() public {
        address to = address(new WrongReturnDataERC721Recipient());
        vm.expectRevert(abi.encodeWithSelector(IERC721Errors.ERC721InvalidReceiver.selector, to));
        _mint(to);
    }

    function test_RevertWhen_mint_WhenTokenIdIsOutOfRange() public mint unlock {
        uint256 NB_OF_TOKENS = baseToken.NB_OF_TOKENS();
        vm.expectRevert(abi.encodeWithSelector(AsideBase.InvalidTokenId.selector, NB_OF_TOKENS));
        vm.prank(minter);
        baseToken.mint(owner, NB_OF_TOKENS);
        vm.expectRevert(abi.encodeWithSelector(AsideBase.InvalidTokenId.selector, NB_OF_TOKENS + 1));
        vm.prank(minter);
        baseToken.mint(owner, NB_OF_TOKENS + 1);
    }

    function test_RevertWhen_mint_WhenTokenIsAlreadyMinted() public mint unlock {
        vm.expectRevert(abi.encodeWithSelector(IERC721Errors.ERC721InvalidSender.selector, address(0)));
        _mint();
    }

    function test_RevertWhen_mint_FromUnauthorized() public {
        vm.expectRevert(
            abi.encodeWithSelector(IAccessControl.AccessControlUnauthorizedAccount.selector, address(this), baseToken.MINTER_ROLE())
        );
        baseToken.mint(owner, tokenId);
    }

    function test_RevertWhen_mint_ToZeroAddress() public {
        vm.expectRevert(abi.encodeWithSelector(IERC721Errors.ERC721InvalidReceiver.selector, address(0)));
        _mint(address(0));
    }
}
