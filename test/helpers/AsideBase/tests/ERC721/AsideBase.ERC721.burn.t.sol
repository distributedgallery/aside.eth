// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.25;

// import {AsideBase, AsideBaseTestHelper, IERC721Errors} from "../../AsideBaseTestHelper.t.sol";

// abstract contract Burn is AsideBaseTestHelper {
//     function test_burn_FromOwner() public mint unlock {
//         vm.expectEmit(true, true, true, true);
//         emit Transfer(owner, address(0), tokenId);
//         vm.prank(owner);
//         baseToken.burn(tokenId);

//         assertEq(baseToken.balanceOf(owner), 0);
//         vm.expectRevert(abi.encodeWithSelector(IERC721Errors.ERC721NonexistentToken.selector, tokenId));
//         baseToken.ownerOf(tokenId);
//     }

//     function test_burn_FromApproved() public mint unlock {
//         vm.prank(owner);
//         baseToken.approve(approved, tokenId);

//         vm.expectEmit(true, true, true, true);
//         emit Transfer(owner, address(0), tokenId);
//         vm.prank(approved);
//         baseToken.burn(tokenId);

//         assertEq(baseToken.balanceOf(owner), 0);
//         vm.expectRevert(abi.encodeWithSelector(IERC721Errors.ERC721NonexistentToken.selector, tokenId));
//         baseToken.getApproved(tokenId);
//         vm.expectRevert(abi.encodeWithSelector(IERC721Errors.ERC721NonexistentToken.selector, tokenId));
//         baseToken.ownerOf(tokenId);
//     }

//     function test_burn_FromOperator() public mint unlock {
//         vm.prank(owner);
//         baseToken.setApprovalForAll(operator, true);

//         vm.expectEmit(true, true, true, true);
//         emit Transfer(owner, address(0), tokenId);
//         vm.prank(operator);
//         baseToken.burn(tokenId);

//         assertEq(baseToken.balanceOf(owner), 0);
//         vm.expectRevert(abi.encodeWithSelector(IERC721Errors.ERC721NonexistentToken.selector, tokenId));
//         baseToken.ownerOf(tokenId);
//     }

//     function test_RevertWhen_burn_ForNonexistentToken() public {
//         vm.expectRevert(abi.encodeWithSelector(IERC721Errors.ERC721NonexistentToken.selector, tokenId));
//         vm.prank(owner);
//         baseToken.burn(tokenId);
//     }

//     function test_RevertWhen_burn_FromUnauthorized() public mint unlock {
//         vm.expectRevert(abi.encodeWithSelector(IERC721Errors.ERC721InsufficientApproval.selector, address(this), tokenId));
//         baseToken.burn(tokenId);
//     }

//     function test_RevertWhen_burn_ForLockedToken() public mint {
//         vm.expectRevert(abi.encodeWithSelector(AsideBase.TokenLocked.selector, tokenId));
//         vm.prank(owner);
//         baseToken.burn(tokenId);
//     }
// }
