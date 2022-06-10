// SPDX-License-Identifier: GPL-3.0-only
pragma solidity ^0.8.0;

// import '@openzeppelin/contracts/token/ERC20/IERC20.sol';
import "../interfaces/IERC20.sol";

library TransferHelper {
    function safeApprove(
        address token,
        address to,
        uint256 value
    ) internal {
        try IERC20(token).approve(to,value){}catch{
            revert("Appro_Failed");
        }
    }

    function safeTransfer(
        address token,
        address to,
        uint256 value
    ) internal {
        try IERC20(token).transfer(to, value){}catch{
            revert("Transfer_Failed");
        }
    }

    function safeTransferFrom(
        address token,
        address from,
        address to,
        uint256 value
    ) internal {
        try IERC20(token).transferFrom(from,to,value){}catch{
            revert("TransferFrom_Failed");
        }
    }

}
