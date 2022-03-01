const ethers = require('ethers');
console.log(ethers.utils.hexZeroPad(("0x3b00ef435fa4fcff5c209a37d1f3dcff37c705ad" + ethers.utils.hexlify(0).substr(2)), 32));