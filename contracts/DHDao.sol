// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "./base/SwapV2.sol";


contract DHDao is Ownable{

    struct Info{
        uint totel;
        uint interval;
        uint startTime;
        uint time;
        address receiver;
    }
    IERC20 token;
    mapping(address => uint) payed;
    Info[] public list;

    function setToekn(IERC20 token_) external onlyOwner(){
        token = token_;
    }
    
    function add(Info[] memory list_) external onlyOwner() {
        for (uint i; i < list_.length; i++) {
            list.push(list_[i]);
        }
    }

    function expected(address account, uint time) public view returns(uint balance){
        Info memory info_ = existed(account);
        if (info_.totel > 0) balance = ((time - info_.startTime) / info_.interval) * info_.totel / (info_.time / info_.interval) - payed[account];
    }

    function withdraw(address account) external{
        uint amount = expected(account, block.timestamp);
        require(amount > 0, "No available");
        payed[account] += amount;
        SafeERC20.safeTransfer(token, account, amount);
    }

    function existed(address account) public view returns(Info memory info_){
        for (uint i; i < list.length; i++) {
            if (list[i].receiver == account) {
                return list[i];
            }
        }
    }

}