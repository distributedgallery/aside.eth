// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import {
    AsideChainlinkTestHelper,
    AsideChainlinkRouter,
    AsideChainlink,
    AsideBase,
    IERC721Errors,
    IAccessControl
} from "../AsideChainlinkTestHelper.t.sol";

abstract contract Update is AsideChainlinkTestHelper {
    function test_update() public update {
        // we cannot check for event data so let's not check data at all and test it on testnets
        vm.expectEmit(true, true, true, false, address(router));
        emit RequestReceived(subscriptionId, new bytes(0), uint16(0), callbackGasLimit, donId);
        _update();
        assertEq(chainlinkToken.lastRequestId(), router.REQUEST_ID());
    }

    function test_RevertWhen_update_FromUnauthorized() public mint {
        vm.expectRevert(
            abi.encodeWithSelector(IAccessControl.AccessControlUnauthorizedAccount.selector, address(this), chainlinkToken.UPDATER_ROLE())
        );
        chainlinkToken.update(new string[](0));
    }
}
