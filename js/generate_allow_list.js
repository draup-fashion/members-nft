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

const loadAllowList = (chain) => {
    const loadedList = fs.readFileSync(`./output/${chain}_seals.txt`, {flag:'r'}).toString().split("\n");
    let parsedList = []
    for(i in loadedList) {
        if (loadedList[i] == "") {
            continue;
        }
        parsedList.push([loadedList[i], "1"]);
    }
    const tree = StandardMerkleTree.of(parsedList, ["address", "uint256"]);
    allowList[chain]['root'] = tree.root;
    console.log(`Merkle Root for ${chain}: `, allowList[chain]['root']);
    let proofList = {}
    for (const [i, v] of tree.entries()) {
        let proof = tree.getProof(i);
        proofList[v[0]] = proof;
    }
    allowList[chain]['proofs'] = proofList;
}

loadAllowList('goerli');
loadAllowList('mainnet');

fs.writeFileSync(`output/draup_seal_allow_list.json`, JSON.stringify(allowList))