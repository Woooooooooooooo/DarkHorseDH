const Airdrop = artifacts.require("Airdrop");
const TestToken = artifacts.require("TestToken");


module.exports = async function(deployer, network, accounts) {

    
    const data = [];
    
    // await deployer.deploy(TestToken, "TDH", "TDH", 100000000);
    // const token = await TestToken.deployed();
    // console.log(web3.utils.fromWei(await token.balanceOf(accounts[0]), "ether"));
    const token = await TestToken.at("0x14fd9c3c3b0c55da8656a53be61910956cf57a7a");
    const address = token.address;
    const cmount = web3.utils.toWei("5", "ether");
    await deployer.deploy(Airdrop, address, cmount);
    // const airdrop = await Airdrop.deployed();
    // const airdrop = await Airdrop.at("0x5Dd7BAC3DDa64577D5409A52b8EAeEb8909a5345");
    await token.approve(Airdrop.address, web3.utils.toWei("10000000", "ether"))
    // const limit = 1000;
    // for (var i = 12000; i < data.length; ) {
    //     console.log("下一次i=" + (i + limit));
    //     await airdrop.send(data.slice(i, i + limit));
    //     i += limit;
    // }

    // console.log(web3.utils.fromWei(await token.balanceOf(data[15647]), "ether"));
    

   

}