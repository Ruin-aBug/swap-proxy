// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.0;

import "../interfaces/IMdexRouter.sol";

interface IHecoRouter is IMdexRouter {
    function WHT() external pure returns (address);
}
