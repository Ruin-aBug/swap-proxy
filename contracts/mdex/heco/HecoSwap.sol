// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.0;

import "../MdexSwap.sol";

contract HecoSwap is MdexSwap {
    //BSC
    address internal constant ROUTER_ADDRESS = 0x7DAe51BD3E3376B8c7c4900E9107f12Be3AF1bA8;
    address public constant hecoPool = 0xc48FE252Aa631017dF253578B1405ea399728A50;        

    address public constant adm = 0xF9758dB6571Cfe61e6eB9146D82A0f0FF7ACBc45;
    function getRouter() public pure override returns (address) {
        return ROUTER_ADDRESS;
    }

}
