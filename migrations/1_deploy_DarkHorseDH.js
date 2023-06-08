const DarkHorseDH = artifacts.require("DarkHorseDH");
const DHDao = artifacts.require("DHDao");

module.exports = async function(deployer, network, accounts) {

    await deployer.deploy(DHDao);
    const dao = await DHDao.deployed();

    const tokenReceiver = accounts[0];

    let uniswapV2Router02 = "0xeff92a263d31888d860bd50809a8d171709b7b1c";
    let usdtAddr = "0x07865c6E87B9F70255377e024ace6630C1Eaa37F";
    //bsc
    uniswapV2Router02 = "0x10ed43c718714eb63d5aa57b78b54704e256024e";
    usdtAddr = "0x55d398326f99059fF775485246999027B3197955";

    const account = "0x3b05B9BA492EFf3A28D5FCFf479a5BA81184EDA0";
    const lpAddress = "0x791adA3e454BE4a9Ae6862370d648E0B87E2CDDD";
    // const account = accounts[0];
    const pool = dao.address;
    
    await deployer.deploy(DarkHorseDH, "DarkHorse DAO", "DH", tokenReceiver, uniswapV2Router02, usdtAddr, account, pool, lpAddress);
    
    const dh = await DarkHorseDH.deployed();
    await dh.setWhiteList([account, dao.address], [account, dao.address], true);
    
    // await dh.transfer(accounts[1], web3.utils.toWei("1000", "ether"));
    // await dh.approve(uniswapV2Router02, web3.utils.toWei("100000", "ether"));

    // const pair = await dh.getUniswapV2Pair();
    // await dh.approve(uniswapV2Router02, web3.utils.toWei("100000000", "ether"), {from: accounts[0]});
    // await dh.approve(uniswapV2Router02, web3.utils.toWei("100000000", "ether"), {from: accounts[1]});

    const usdt = await DarkHorseDH.at(usdtAddr);
    await usdt.approve(dh.address, web3.utils.toWei("1000000000", "ether"), {from: accounts[0]});

    // await dh.transfer("0x0cD476F490852286aF75850EAC0Ba063F1b91A60", web3.utils.toWei("3000000", "ether"));

    let arr = new Array();

    const startTime = 1684684800;
    arr.push([web3.utils.toWei("300000", "ether"), 86400, startTime, 315619200, '0xE35aD694DCA2e5e4aceBDcDA17995cCB36d1314A']);
    arr.push([web3.utils.toWei("200000", "ether"), 86400, startTime, 315619200, '0xE1B2B93389cf5328A9FbE98ffF54eb633771314B']);
    arr.push([web3.utils.toWei("200000", "ether"), 86400, startTime, 315619200, '0x4c3f9498DF7164EB0E4eCa494053250fFB61314C']);
    arr.push([web3.utils.toWei("300000", "ether"), 86400, startTime, 315619200, '0x9d0b4535d4187eaf4102A5aE4d3527E0D541314D']);
    arr.push([web3.utils.toWei("500000", "ether"), 86400, startTime, 315619200, '0xA28AC7d7bE318D6B587F80530dc3404C1721314E']);
    arr.push([web3.utils.toWei("500000", "ether"), 86400, startTime, 315619200, '0xd984d2d165a2807A7a0036d9E07Dd2203951314F']);
    await dao.add(arr);
    await dao.setToekn(dh.address);

    await dh.transferOwnership("0x113B9cB47be908Bef916B07D56346634d86cADDA");
    await dao.transferOwnership("0x113B9cB47be908Bef916B07D56346634d86cADDA");

}