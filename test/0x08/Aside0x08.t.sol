// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.25;

import {Aside0x08, Aside0x08TestHelper, IAccessControl} from "./Aside0x08TestHelper.t.sol";
import {AsideBaseTest} from "../helpers/AsideBase/tests/AsideBase.t.sol";

contract Aside0x08BaseTest is Aside0x08TestHelper {
    event BatchMetadataUpdate(uint256 _fromTokenId, uint256 _toTokenId);
    event Unlock();

    function test_NB_OF_TOKENS() public {
        assertEq(token.NB_OF_TOKENS(), 65);
    }

    function test_unlock() public {
        assertFalse(token.isUnlocked());
        vm.expectEmit(address(token));
        emit BatchMetadataUpdate(0, type(uint256).max);
        emit Unlock();
        vm.prank(unlocker);
        token.unlock();
        assertTrue(token.isUnlocked());
    }

    function test_RevertWhen_unlock_WhenAlreadyUnlocked() public unlock {
        vm.expectRevert(
            abi.encodeWithSelector(Aside0x08.AlreadyUnlocked.selector)
        );
        vm.prank(unlocker);
        token.unlock();
    }

    function test_RevertWhen_unlock_FromUnauthorized() public {
        vm.expectRevert(
            abi.encodeWithSelector(
                IAccessControl.AccessControlUnauthorizedAccount.selector,
                address(this),
                token.UNLOCKER_ROLE()
            )
        );
        token.unlock();
    }

    function test_withdraw() public {
        address payable to = payable(
            address(0xB64cAE0AEA0C888142C70d7f2474fD6D7E42739E)
        );
        vm.warp(token.saleOpening());
        token.mint{value: token.PRICE()}(owner);
        token.mint{value: token.PRICE()}(owner);
        token.mint{value: token.PRICE()}(owner);
        assertEq(address(token).balance, token.PRICE() * 3);
        assertEq(to.balance, 0);
        vm.prank(admin);
        token.withdraw(to);
        assertEq(address(token).balance, 0);
        assertEq(to.balance, token.PRICE() * 3);
    }

    function test_RevertWhen_withdraw_ToZeroAddress() public {
        vm.expectRevert();
        vm.prank(admin);
        token.withdraw(payable(address(0)));
    }

    function test_RevertWhen_withdraw_FromAuauthorized() public {
        vm.expectRevert(
            abi.encodeWithSelector(
                IAccessControl.AccessControlUnauthorizedAccount.selector,
                address(this),
                token.DEFAULT_ADMIN_ROLE()
            )
        );
        token.withdraw(payable(admin));
    }

    //////////////////////////////////////////////////////////
    // Sale-related functions
    //////////////////////////////////////////////////////////

    function test_pauseSale() public {
        assertFalse(token.isSalePaused());
        vm.prank(admin);
        token.pauseSale();
        assertTrue(token.isSalePaused());
    }

    function test_RevertWhen_pauseSale_FromUnauthorized() public {
        vm.expectRevert(
            abi.encodeWithSelector(
                IAccessControl.AccessControlUnauthorizedAccount.selector,
                address(this),
                token.DEFAULT_ADMIN_ROLE()
            )
        );
        token.pauseSale();
    }

    function test_unpauseSale() public {
        vm.prank(admin);
        token.pauseSale();
        assertTrue(token.isSalePaused());
        vm.prank(admin);
        token.unpauseSale();
        assertFalse(token.isSalePaused());
    }

    function test_RevertWhen_unpauseSale_FromUnauthorized() public {
        vm.expectRevert(
            abi.encodeWithSelector(
                IAccessControl.AccessControlUnauthorizedAccount.selector,
                address(this),
                token.DEFAULT_ADMIN_ROLE()
            )
        );
        token.unpauseSale();
    }

    function test_setSaleOpening() public {
        vm.prank(admin);
        token.setSaleOpening(9999);
        assertEq(token.saleOpening(), 9999);
    }

    function test_RevertWhen_setSaleOpening_FromUnauthorized() public {
        vm.expectRevert(
            abi.encodeWithSelector(
                IAccessControl.AccessControlUnauthorizedAccount.selector,
                address(this),
                token.DEFAULT_ADMIN_ROLE()
            )
        );
        token.setSaleOpening(4);
    }

    function test_isSaleOpened() public {
        assertFalse(token.isSalePaused());
        vm.warp(1);
        assertFalse(token.isSaleOpened());
        vm.warp(token.saleOpening() - 1);
        assertFalse(token.isSaleOpened());
        vm.warp(token.saleOpening());
        assertTrue(token.isSaleOpened());
        vm.prank(admin);
        token.pauseSale();
        assertFalse(token.isSaleOpened());
    }

    //////////////////////////////////////////////////////////
    // Mint-related functions
    //////////////////////////////////////////////////////////

    function test_mint() public {
        vm.warp(token.saleOpening());
        token.mint{value: token.PRICE()}(owner);
        assertEq(token.ownerOf(0), owner);
        assertEq(token.balanceOf(owner), 1);
        assertEq(token.editionCount(), 1);
        token.mint{value: token.PRICE()}(owner);
        assertEq(token.ownerOf(0), owner);
        assertEq(token.ownerOf(1), owner);
        assertEq(token.balanceOf(owner), 2);
        assertEq(token.editionCount(), 2);
    }

    function test_RevertWhen_mint_WhenSaleIsNotOpenedYet() public {
        vm.warp(1);
        vm.expectRevert(
            abi.encodeWithSelector(Aside0x08.SaleNotOpened.selector)
        );
        token.mint(owner);
    }

    function test_RevertWhen_mint_WhenSaleIsPaused() public {
        vm.warp(token.saleOpening());
        vm.prank(admin);
        token.pauseSale();
        vm.expectRevert(
            abi.encodeWithSelector(Aside0x08.SaleNotOpened.selector)
        );
        token.mint(owner);
    }

    function test_RevertWhen_mint_WhenAllTokensAreAlreadyMinted() public {
        vm.warp(token.saleOpening());
        for (uint i = 0; i < token.NB_OF_TOKENS(); i++) {
            token.mint{value: token.PRICE()}(owner);
        }
        assertEq(token.editionCount(), 65);
        vm.expectRevert(abi.encodeWithSelector(Aside0x08.NoTokenLeft.selector));
        token.mint(owner);
    }

    function test_RevertWhen_mint_WhenPriceIsInvalid() public {
        vm.warp(token.saleOpening());
        vm.expectRevert(
            abi.encodeWithSelector(Aside0x08.InvalidPrice.selector)
        );
        token.mint(owner);
        // vm.expectRevert(
        //     abi.encodeWithSelector(Aside0x08.InvalidPrice.selector)
        // );
        // token.mint{value: token.PRICE() + 1}(owner);
    }
}
