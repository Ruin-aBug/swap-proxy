// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.0;

library Library {

    function sortTokens(address tokenA, address tokenB)
        internal
        pure
        returns (address token0, address token1)
    {
        require(tokenA != tokenB, "UniswapV2Library: IDENTICAL_ADDRESSES");
        (token0, token1) = tokenA < tokenB
            ? (tokenA, tokenB)
            : (tokenB, tokenA);
        require(token0 != address(0), "UniswapV2Library: ZERO_ADDRESS");
    }

    function uintArryToAddrArry(uint256[] memory addrArray) internal pure returns(address[] memory){
        address[] memory addrs = new address[](addrArray.length);
        for (uint256 i; i < addrArray.length; i++) {
            addrs[i] = address(uint160(addrArray[i]));
        }
        return addrs;
    }

    function getConverData(uint256 data) internal pure returns (uint24 a, int24 b, int24 c) {
        a = uint24(data & 0xFFFFFF);
        uint256 testb = (data & 0x800000000000);
        uint256 testc = (data & 0x800000000000000000);
        uint24 dataMin = uint24(data >> 0x18);
        b = int24(dataMin & 0x7FFFFF);
        if (testb > 0) {
            b = -b;
        }
        uint24 dataMax = uint24(data >> 0x30);
        c = int24(dataMax & 0x7FFFFF);
        if (testc > 0) {
            c = -c;
        }
    }
}
