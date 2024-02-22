// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import "forge-std/Script.sol";
import {Aside0x01} from "../src/Aside0x01.sol";

contract DeployAside0x01 is Script {
    address public constant ADMIN = 0x3c7e48216C74D7818aB1Fd226e56C60C4D659bA6;
    address public constant MINTER = 0x3c7e48216C74D7818aB1Fd226e56C60C4D659bA6;
    uint256 public constant TIMELOCK = 1 weeks;
    address public constant SEPOLIA_ROUTER = 0xb83E47C2bC239B3bf370bc41e1459A34b41238D0;
    bytes32 public constant SEPOLIA_DON_ID = 0x66756e2d657468657265756d2d7365706f6c69612d3100000000000000000000;
    uint64 public constant SUBSCRIPTION_ID = uint64(1900);
    uint32 public constant CALLBACK_GAS_LIMIT = 100_000;
    string public constant SOURCE =
        "const response = await Functions.makeHttpRequest({url:'https://aside-distributedgallery.vercel.app/api/aisentiment', method:'GET'});if (response.error) {throw Error('Request failed');}return Functions.encodeUint256(response.data.sentiment);";

    function run() external {
        vm.startBroadcast();

        Aside0x01 token =
            new Aside0x01(ADMIN, MINTER, TIMELOCK, SEPOLIA_ROUTER, SEPOLIA_DON_ID, SUBSCRIPTION_ID, CALLBACK_GAS_LIMIT, SOURCE);

        vm.stopBroadcast();
    }
}
