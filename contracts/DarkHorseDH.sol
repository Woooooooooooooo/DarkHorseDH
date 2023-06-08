// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@uniswap/v2-core/contracts/interfaces/IUniswapV2Factory.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Address.sol";
import "./base/SwapV2.sol";

contract DarkHorseDH is ERC20Burnable, SwapV2, Ownable{

    struct Fee{
        uint baseProportion;
        uint buyBurn;
        uint buySafeFundProportion;
        uint buyRiskFundProportion;
        uint buyDaoFundProportion;
        uint sellBurn;
        uint sellDaoFundProportion;
        uint sellLp;
        address buySafeFundAddress;
        address buyRiskFundAddress;
        address buyDaoFundAddress;
    }

    struct Info{
        uint burnMax;
        uint sellMax;
        uint interval;
        uint intervalMax;
        uint addLPAmount;
    }

    struct SellInfo{
        uint time;
        uint amount;
    }

    uint private _burnNum = 0;
    IUniswapV2Pair private _uniswapV2Pair;
    IUniswapV2Router02 private _uniswapV2Router02;
    mapping(address => bool) public whiteListFrom;
    mapping(address => bool) public whiteListTo;
    mapping(address => bool) public pairs;
    mapping(address => SellInfo) private _sellInfo;
    Fee public fee;
    Info public info;

    constructor(string memory name_, string memory symbol_, address tokenReceiver, IUniswapV2Router02 uniswapV2Router02, address usdt,  address account, address pool, address lpAddress_) ERC20(name_, symbol_) SwapV2(tokenReceiver, lpAddress_) {
        _mint(account, 3201314 ether);
        _mint(pool, 2000000 ether);
        
        fee.baseProportion = 10000;
        fee.buyBurn = 100;
        fee.buySafeFundProportion = 100;
        fee.buyRiskFundProportion = 100;
        fee.buyDaoFundProportion = 200;
        fee.sellBurn = 100;
        fee.sellLp = 400;
        fee.buyDaoFundAddress = 0xe95D64b950AfC8AE24C43C296B939932Da70CCCC;
        fee.buySafeFundAddress = 0x63adE420f43bAc025B196B01DfC018ec67cFCAAA;
        fee.buyRiskFundAddress = 0xa7bB1c813b7Dc5db8EdDe90f09F57b855Ed6CBBB;

        info.burnMax = 4991314 ether;
        info.sellMax = 100 ether;
        info.interval = 1 days;
        info.intervalMax = 500 ether;
        info.addLPAmount = 10 ether;

        _uniswapV2Router02 = uniswapV2Router02;
        _uniswapV2Pair = IUniswapV2Pair(IUniswapV2Factory(_uniswapV2Router02.factory()).createPair(usdt, address(this)));
        pairs[address(_uniswapV2Pair)] = true;
    }

    function setInfo(Info calldata info_) external onlyOwner() {
        info = info_;
    }

    function setFee(Fee calldata fee_) external onlyOwner() {
        fee = fee_;
    }

    function setWhiteList(address[] calldata from, address[] calldata to, bool whiteList_) external onlyOwner() {
        for (uint i; i < from.length; i++) {
            whiteListFrom[from[i]] = whiteList_;
        }
        for (uint i; i < to.length; i++) {
            whiteListTo[to[i]] = whiteList_;
        }
    }

    function setPairs(address[] calldata addr, bool pairs_) external onlyOwner() {
        for (uint i; i < addr.length; i++) {
            pairs[addr[i]] = pairs_;
        }
    }

    function _isUniswapPair(address addr) internal view override returns (bool) {
        return pairs[addr];
    }

    function getUniswapV2Pair() public view override returns(IUniswapV2Pair){ 
        return _uniswapV2Pair;
    }

    function getUniswapV2Router02() public view override returns(IUniswapV2Router02) {
        return _uniswapV2Router02;
    }

    function _approve(address owner, address spender, uint256 amount) internal override(ERC20, SwapV2){
        ERC20._approve(owner, spender, amount);
        
    }

    function _transfer(
        address from,
        address to,
        uint256 amount
    ) internal override {
        if (from == address(this) || to == address(this)) {
            super._transfer(from, to, amount);
            return;
        }
        
        if (balanceOf(from) == amount) amount -= 1000000 gwei;
        if (whiteListFrom[from] || whiteListTo[to]) {
            super._transfer(from, to, amount);
            return;
        }
       
        (bool isAdd,bool isDel) = _isLiquidity(from, to);
        if (isAdd || isDel) {
            super._transfer(from, to, amount);
            return;
        }

        require(info.sellMax >= amount || _isUniswapPair(from), "EXCEEDS LIMIT");
        if (_sellInfo[from].time + info.interval <= block.timestamp) {
            _sellInfo[from].time = block.timestamp;
            _sellInfo[from].amount = 0;
        }
        _sellInfo[from].amount += amount;
        require(_sellInfo[from].amount <= info.intervalMax  || _isUniswapPair(from), "EXCEEDS LIMIT");
        uint repel;
        if (_isUniswapPair(from) || (!Address.isContract(from) && !_isUniswapPair(to))) {
            repel = 1;
            uint burn = amount * fee.buyBurn / fee.baseProportion;
            _buySellBurn(from, burn);
            uint safe = amount * fee.buySafeFundProportion / fee.baseProportion;
            super._transfer(from, fee.buySafeFundAddress, safe);
            uint risk = amount * fee.buyRiskFundProportion / fee.baseProportion;
            super._transfer(from, fee.buyRiskFundAddress, risk);
            uint dao = amount * fee.buyDaoFundProportion / fee.baseProportion;
            super._transfer(from, fee.buyDaoFundAddress, dao);
            amount = amount - burn - safe - risk - dao;
        }

        if (repel == 0 && _isUniswapPair(to)) {
            uint burn = amount * fee.sellBurn / fee.baseProportion;
            _buySellBurn(from, burn);
            uint lp = amount * fee.sellLp / fee.baseProportion;
            super._transfer(from, address(this), lp);
            SwapV2._addPool(lp);
            amount = amount - burn - lp;
            if (balanceOf(address(this)) >= info.addLPAmount) SwapV2._addLiquidity();
        }

        super._transfer(from, to, amount);
    }

    function _buySellBurn(address from, uint burn) internal {
        if (_burnNum >= info.burnMax) {
            super._transfer(from, fee.buyDaoFundAddress, burn);
            return;
        }
        _burn(from, burn);
        _burnNum += burn;
    }

   
}