// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@uniswap/v2-core/contracts/interfaces/IUniswapV2Factory.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "./base/SwapV2.sol";

contract TestV2 {

    address _tokenReceiver = 0xfF09D32e3288bD19f56caF2C79F0bF31497D84a8;
    IERC20 erc20 = IERC20(0x93a511062654909BC351F9837e9C8002f7C3397d);


    function getUniswapV2Pair() public view virtual returns(IUniswapV2Pair){
        return IUniswapV2Pair(0xCA7702b414f633ba1FEC228D4774263E2eFd732D);
    }

    function getUniswapV2Router02() public view virtual returns(IUniswapV2Router02) {
        return IUniswapV2Router02(0xEfF92A263d31888d860bD50809A8D171709b7b1c);
    }
    

    function addLiquidity(uint256 amount) public{
        address token = getUniswapV2Pair().token0();
        token = token != address(erc20) ? token : getUniswapV2Pair().token1();
        uint256 amountOut = IERC20(token).balanceOf(_tokenReceiver);
        erc20.approve(address(getUniswapV2Router02()), amount);
        amount = amount / 2;
        address[] memory path = new address[](2);
        path[0] = address(erc20);
        path[1] = token;
        
        getUniswapV2Router02().swapExactTokensForTokensSupportingFeeOnTransferTokens(
            amount, 
            0,
            path,
            _tokenReceiver,
            block.timestamp
        );
        amountOut = IERC20(token).balanceOf(_tokenReceiver) - amountOut;
        IERC20(token).transferFrom(_tokenReceiver, address(this), amountOut);

        IERC20(token).approve(address(getUniswapV2Router02()), amountOut);
        getUniswapV2Router02().addLiquidity(
            token,
            address(erc20),
            amountOut,
            amount,
            0, // slippage is unavoidable
            0, // slippage is unavoidable
            _tokenReceiver,
            block.timestamp
        );
    }
}