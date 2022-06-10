// SPDX-License-Identifier: MIT

pragma solidity >=0.7.5;
pragma abicoder v2;

/// @title Quoter Interface

interface IQuoter {

	function quoteExactInput(bytes memory path, uint256 amountIn) external returns (uint256 amountOut);


	function quoteExactInputSingle(
		address tokenIn,
		address tokenOut,
		uint24 fee,
		uint256 amountIn,
		uint160 sqrtPriceLimitX96
	) external returns (uint256 amountOut);

	function quoteExactOutput(bytes memory path, uint256 amountOut) external returns (uint256 amountIn);

	function quoteExactOutputSingle(
		address tokenIn,
		address tokenOut,
		uint24 fee,
		uint256 amountOut,
		uint160 sqrtPriceLimitX96
	) external returns (uint256 amountIn);
}
