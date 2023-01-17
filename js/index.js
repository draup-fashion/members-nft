const { StandardMerkleTree } = require("@openzeppelin/merkle-tree");
const fs = require('fs');

// (1)
// values from AllowListTest.sol
const minterAddress = "0x030f6a4c5baa7350405fa8122cf458070abd1b59"
const values = [
  ["0xc765Dc103d13f3336aD5ec3c4726dEf1C6f6A3D7", "1"],
  ["0x8d0f68bCF513e0e55cB3C18fCf5feb8dBd0d9C16", "1"],
];

// (2)
const tree = StandardMerkleTree.of(values, ["address", "uint256"]);

// (3)
console.log('Merkle Root:', tree.root);

// (4)
const filePrefix = Date.now();
const year = new Date().getFullYear();
const month = new Date().getMonth() + 1;
const day = new Date().getDate();
//fs.writeFileSync(`output/mainnet/${year}-${month}-${day}-${filePrefix}-merkle-tree.json`, JSON.stringify(tree.dump()));



// (5) generate a proof
for (const [i, v] of tree.entries()) {
  if (v[0] === "0x8d0f68bCF513e0e55cB3C18fCf5feb8dBd0d9C16") {
    const proof = tree.getProof(i);
    console.log('Value:', v);
    console.log('Proof:', proof);
  }
}

