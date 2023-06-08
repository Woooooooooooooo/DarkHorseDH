// SPDX-License-Identifier:  GPL-3.0-or-later

pragma solidity ^0.8.17;


import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract Airdrop{

    IERC20 _tokenAddr;
    uint _amount;

    constructor (IERC20 tokenAddr, uint amount) {
        _tokenAddr = tokenAddr;
        _amount = amount;
    }

    function send(address[] calldata data) public payable {
        IERC20 tokenAddr = _tokenAddr; uint amount = _amount;
        for (uint256 i = 0; i < data.length; i++) {
            SafeERC20.safeTransferFrom(tokenAddr, msg.sender, data[i], amount);
        }
    }

  

}