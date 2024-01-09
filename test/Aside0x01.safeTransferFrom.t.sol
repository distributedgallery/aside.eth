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

/*
 * Safely transfers `tokenId` token from from to to.
 *
 * Requirements:
 *  - `from` cannot be the zero address.
 *  - `to` cannot be the zero address.
 *  - `tokenId` token must exist and be owned by `from`.
 *  - If the caller is not from, it must be approved to move this token by either approve or setApprovalForAll.
 *  - If to refers to a smart contract, it must implement IERC721Receiver.onERC721Received, which is called upon a safe transfer.
 *  - Emits a Transfer event.
*/
contract Transfer is TestHelper {
    function test_safeTransferFromToEAO() public mint unlock {
        vm.prank(owner);
        token.setApprovalForAll(address(this), true);

        vm.expectEmit(true, true, true, true);
        emit Transfer(owner, recipient, tokenId);
        token.safeTransferFrom(owner, recipient, tokenId, "this is a test");

        assertEq(token.getApproved(tokenId), address(0));
        assertEq(token.ownerOf(tokenId), recipient);
        assertEq(token.balanceOf(recipient), 1);
        assertEq(token.balanceOf(owner), 0);
    }

    function test_safeTransferFromToERC721Recipient() public mint unlock {
        ERC721Recipient recipient = new ERC721Recipient();

        vm.prank(owner);
        token.setApprovalForAll(address(this), true);

        vm.expectEmit(true, true, true, true);
        emit Transfer(owner, address(recipient), tokenId);
        token.safeTransferFrom(owner, address(recipient), tokenId);

        assertEq(token.getApproved(tokenId), address(0));
        assertEq(token.ownerOf(tokenId), address(recipient));
        assertEq(token.balanceOf(address(recipient)), 1);
        assertEq(token.balanceOf(owner), 0);

        assertEq(recipient.operator(), address(this));
        assertEq(recipient.from(), owner);
        assertEq(recipient.id(), tokenId);
        assertEq(recipient.data(), "");
    }

    function test_safeTransferFromToERC721RecipientWithData() public mint unlock {
        ERC721Recipient recipient = new ERC721Recipient();

        vm.prank(owner);
        token.setApprovalForAll(address(this), true);

        vm.expectEmit(true, true, true, true);
        emit Transfer(owner, address(recipient), tokenId);
        token.safeTransferFrom(owner, address(recipient), tokenId, "this is a test");

        assertEq(token.getApproved(tokenId), address(0));
        assertEq(token.ownerOf(tokenId), address(recipient));
        assertEq(token.balanceOf(address(recipient)), 1);
        assertEq(token.balanceOf(owner), 0);

        assertEq(recipient.operator(), address(this));
        assertEq(recipient.from(), owner);
        assertEq(recipient.id(), tokenId);
        assertEq(recipient.data(), "this is a test");
    }

    // function test_transferFrom_RevertWhenTokenIsStillLocked() public {
    //     vm.expectRevert(abi.encodeWithSelector(Aside0x01.TokenLocked.selector, 0));
    //     token.transferFrom(owners[0], owners[1], 0);
    // }

    function test_revertWhenTransferFromUnOwned() public mint unlock {
        vm.expectRevert(abi.encodeWithSelector(IERC721Errors.ERC721NonexistentToken.selector, 99999));
        vm.prank(owner);
        token.safeTransferFrom(owner, recipient, 99999);
    }

    function test_revertWhenSafeTransferFromWrongFrom() public mint unlock {
        vm.expectRevert(
            abi.encodeWithSelector(IERC721Errors.ERC721IncorrectOwner.selector, address(0xDEAD), tokenId, owner)
        );
        vm.prank(owner);
        token.transferFrom(address(0xDEAD), recipient, tokenId);
    }

    function test_revertWhenSafeTransferFromToZero() public mint unlock {
        vm.expectRevert(abi.encodeWithSelector(IERC721Errors.ERC721InvalidReceiver.selector, address(0)));
        vm.prank(owner);
        token.transferFrom(owner, address(0), tokenId);
    }

    function test_revertWhenTransferFromNotOwner() public mint unlock {
        vm.expectRevert(
            abi.encodeWithSelector(IERC721Errors.ERC721InsufficientApproval.selector, address(this), tokenId)
        );

        token.transferFrom(owner, recipient, tokenId);
    }

    // #region NonERC721Recipient
    function test_revertWhenSafeTransferFromToNonERC721Recipient() public mint unlock {
        NonERC721Recipient recipient = new NonERC721Recipient();

        vm.expectRevert(abi.encodeWithSelector(IERC721Errors.ERC721InvalidReceiver.selector, address(recipient)));
        vm.prank(owner);
        token.safeTransferFrom(owner, address(recipient), tokenId);
    }

    function test_revertWhenSafeTransferFromToNonERC721RecipientWithData() public mint unlock {
        NonERC721Recipient recipient = new NonERC721Recipient();

        vm.expectRevert(abi.encodeWithSelector(IERC721Errors.ERC721InvalidReceiver.selector, address(recipient)));
        vm.prank(owner);
        token.safeTransferFrom(owner, address(recipient), tokenId, "this is a test");
    }
    // #endregion

    // #region RevertingERC721Recipient
    function test_revertWhenSafeTransferFromToRevertingERC721Recipient() public mint unlock {
        RevertingERC721Recipient recipient = new RevertingERC721Recipient();

        vm.expectRevert(abi.encodeWithSelector(IERC721Receiver.onERC721Received.selector));
        vm.prank(owner);
        token.safeTransferFrom(owner, address(recipient), tokenId);
    }

    function test_revertWhenSafeTransferFromToRevertingERC721RecipientWithData() public mint unlock {
        RevertingERC721Recipient recipient = new RevertingERC721Recipient();

        _unlock();
        vm.expectRevert(abi.encodeWithSelector(IERC721Receiver.onERC721Received.selector));
        vm.prank(owner);
        token.safeTransferFrom(owner, address(recipient), tokenId, "this is a test");
    }
    // #endregion

    // #region ERC721RecipientWithWrongReturnData
    function test_revertWhenSafeTransferFromERC721RecipientWithWrongReturnData() public mint unlock {
        address recipient = address(new WrongReturnDataERC721Recipient());

        vm.expectRevert(abi.encodeWithSelector(IERC721Errors.ERC721InvalidReceiver.selector, address(recipient)));
        vm.prank(owner);
        token.safeTransferFrom(owner, recipient, tokenId);
    }

    function test_revertWhenSafeTransferFromERC721RecipientWithWrongReturnDataWithData() public mint unlock {
        address recipient = address(new WrongReturnDataERC721Recipient());

        vm.expectRevert(abi.encodeWithSelector(IERC721Errors.ERC721InvalidReceiver.selector, address(recipient)));
        vm.prank(owner);
        token.safeTransferFrom(owner, recipient, tokenId, "this is a test");
    }

    //#endregion

    function test_transferFrom_RevertWhenTokenIsStillLocked() public mint {
        // revert when caller is owner
        vm.expectRevert(abi.encodeWithSelector(Aside0x01.TokenLocked.selector, 0));
        token.transferFrom(owners[0], owners[1], 0);
        // revert when caller is approved
        vm.prank(owners[0]);
        token.approve(owners[1], 0);
        vm.prank(owners[1]);
        vm.expectRevert(abi.encodeWithSelector(Aside0x01.TokenLocked.selector, 0));
        token.transferFrom(owners[0], owners[1], 0);
        // revert when caller is approved for all
        vm.prank(owners[0]);
        token.setApprovalForAll(owners[0], true);
        vm.expectRevert(abi.encodeWithSelector(Aside0x01.TokenLocked.selector, 0));
        token.transferFrom(owners[0], owners[1], 0);
    }

    function test_transferFrom_RevertFromZero() public mint unlock {
        vm.prank(owners[0]);
        vm.expectRevert(abi.encodeWithSelector(IERC721Errors.ERC721IncorrectOwner.selector, address(0), 0, owners[0]));
        token.transferFrom(address(0), owners[1], 0);
    }

    function test_transferFrom_RevertToZero() public mint unlock {
        vm.prank(owners[0]);
        vm.expectRevert(abi.encodeWithSelector(IERC721Errors.ERC721InvalidReceiver.selector, address(0)));

        token.transferFrom(owners[0], address(0), 0);
    }
}
