const { StandardMerkleTree } = require("@openzeppelin/merkle-tree");
const fs = require('fs');

const allowList = {
    'goerli': {
        'root': '0x0',
        'proofs': {
        }
    },
    'mainnet': {
        'root': '0x0',
        'proofs': {
        }
    }
}

const goerliList = fs.readFileSync('./output/goerli_seals.txt', {flag:'r'}).toString().split("\n");

let gList = []
for(i in goerliList) {
    gList.push([goerliList[i], "1"]);
}

const tree = StandardMerkleTree.of(gList, ["address", "uint256"]);
allowList['goerli']['root'] = tree.root;
console.log('Merkle Root:', allowList['goerli']['root']);

let proofList = {}
for (const [i, v] of tree.entries()) {
    let proof = tree.getProof(i);
    proofList[v[0]] = proof;
    console.log('Value:', v);
    console.log('Proof:', proof);
}
allowList['goerli']['proofs'] = proofList;

fs.writeFileSync(`output/draup_seal_allow_list.json`, JSON.stringify(allowList))