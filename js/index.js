const { StandardMerkleTree } = require("@openzeppelin/merkle-tree");
const fs = require('fs');

// (1)
// values from AllowListTest.sol
const minterAddress = "0x030f6a4c5baa7350405fa8122cf458070abd1b59"
const values = [
  ["0x7c8999dc9a822c1f0df42023113edb4fdd543266", "1"],
  [minterAddress, "1"],
  ["0xDAFEA492D9c6733ae3d56b7Ed1ADB60692c98Bc5", "1"],
  ["0xeD33259a056F4fb449FFB7B7E2eCB43a9B5685Bf", "1"],
  ["0x502367Ea6eA7ED256A55Ff70340EB81bF0e11bC2", "1"],
  ["0x6ec88a2Cb932eb46dfda0280c0eadB93b6eCa13B", "1"],
  ["0x85226df654042ff34e1386dfcb1f32762b4793e4", "1"],
  ["0xdAC17F958D2ee523a2206206994597C13D831ec7", "1"],
  ["0x9a66644084108a1bC23A9cCd50d6d63E53098dB6", "1"],
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
fs.writeFileSync(`output/${year}-${month}-${day}-${filePrefix}-merkle-tree.json`, JSON.stringify(tree.dump()));



// (5) generate a proof
for (const [i, v] of tree.entries()) {
  if (v[0] === minterAddress) {
    const proof = tree.getProof(i);
    console.log('Value:', v);
    console.log('Proof:', proof);
  }
}

