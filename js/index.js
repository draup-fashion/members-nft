const { StandardMerkleTree } = require("@openzeppelin/merkle-tree");
const fs = require('fs');

// (1)
const values = [
  ["0x1111111111111111111111111111111111111111", "5000000000000000000"],
  ["0x2222222222222222222222222222222222222222", "2500000000000000000"]
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