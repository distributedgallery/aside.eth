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

abstract contract MintBatch is AsideBaseTestHelper {
    function test_mintBatch_ToEOA() public {
        vm.expectEmit(address(baseToken));
        emit Transfer(address(0), owner, tokenId);
        vm.expectEmit(address(baseToken));
        emit Transfer(address(0), recipient, tokenId + 1);
        _mintBatch();

        assertEq(baseToken.ownerOf(tokenId), owner);
        assertEq(baseToken.balanceOf(owner), 1);
        assertEq(baseToken.tokenURI(tokenId), tokenURI);
        assertEq(baseToken.ownerOf(tokenId + 1), recipient);
        assertEq(baseToken.balanceOf(recipient), 1);
    }

    function test_mintBatch_ToERC721Recipient() public {
        ERC721Recipient to = new ERC721Recipient();
        vm.expectEmit(address(baseToken));
        emit Transfer(address(0), address(to), tokenId);
        vm.expectEmit(address(baseToken));
        emit Transfer(address(0), address(to), tokenId + 1);
        _mintBatch(address(to));

        assertEq(baseToken.ownerOf(tokenId), address(to));
        assertEq(baseToken.ownerOf(tokenId + 1), address(to));
        assertEq(baseToken.balanceOf(address(to)), 2);
        assertEq(baseToken.tokenURI(tokenId), tokenURI);

        assertEq(to.operator(), minter);
        assertEq(to.from(), address(0));
        assertEq(to.id(), tokenId + 1);
        assertEq(to.data(), "");
    }

    function test_RevertWhen_mintBatch_ToNonERC721Recipient() public {
        address to = address(new NonERC721Recipient());
        vm.expectRevert(abi.encodeWithSelector(IERC721Errors.ERC721InvalidReceiver.selector, to));
        _mintBatch(to);
    }

    function test_RevertWhen_mintBatch_ToRevertingERC721Recipient() public {
        address to = address(new RevertingERC721Recipient());
        vm.expectRevert(abi.encodeWithSelector(IERC721Receiver.onERC721Received.selector));
        _mintBatch(to);
    }

    function test_RevertWhen_mintBatch_ToWrongReturnDataERC721Recipient() public {
        address to = address(new WrongReturnDataERC721Recipient());
        vm.expectRevert(abi.encodeWithSelector(IERC721Errors.ERC721InvalidReceiver.selector, to));
        _mintBatch(to);
    }

    function test_RevertWhen_mintBatch_WhenTokenIsAlreadyMinted() public mint unlock {
        vm.expectRevert(abi.encodeWithSelector(IERC721Errors.ERC721InvalidSender.selector, address(0)));
        _mintBatch();
    }

    function test_RevertWhen_mintBatch_FromUnauthorized() public {
        address[] memory to = new address[](1);
        uint256[] memory tokenIds = new uint256[](1);
        to[0] = owner;
        tokenIds[0] = tokenId;
        vm.expectRevert(
            abi.encodeWithSelector(IAccessControl.AccessControlUnauthorizedAccount.selector, address(this), baseToken.MINTER_ROLE())
        );
        baseToken.mintBatch(to, tokenIds);
    }

    function test_RevertWhen_mintBatch_ToZeroAddress() public {
        vm.expectRevert(abi.encodeWithSelector(IERC721Errors.ERC721InvalidReceiver.selector, address(0)));
        _mintBatch(address(0));
    }

    function test_RevertWhen_mintBatch_WithInvalidParametersMatch() public {
        address[] memory to = new address[](1);
        uint256[] memory tokenIds = new uint256[](2);
        vm.expectRevert(abi.encodeWithSelector(AsideBase.InvalidParametersMatch.selector));
        vm.prank(minter);
        baseToken.mintBatch(to, tokenIds);
    }
}
