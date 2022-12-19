// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import "openzeppelin-contracts/contracts/access/Ownable.sol";
import "openzeppelin-contracts/contracts/token/ERC721/ERC721.sol";
import "openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";
import "openzeppelin-contracts/contracts/utils/cryptography/MerkleProof.sol";

contract DraupMembershipERC721 is ERC721, Ownable {
    uint256 public immutable MAX_SUPPLY = 989;
    uint256 public immutable ROYALTY = 7500;
    constructor() ERC721("Draup Membership", "DRAUP") {}

    uint256 public nextTokenId;
    bytes32 public merkleRoot;
    string _BaseURI = "test";

    // Mapping to track who used their allowlist spot
    mapping(address => bool) public claimed;

    error InvalidProof();
    error AlreadyClaimed();

    function toBytes32(address addr) pure internal returns (bytes32) {
        return bytes32(uint256(uint160(addr)));
    }

    function mint(bytes32[] calldata merkleProof) public {
        bytes32 leaf = keccak256(bytes.concat(keccak256(abi.encode(msg.sender, 1))));
        if (!MerkleProof.verify(merkleProof, merkleRoot, leaf)) {
            revert InvalidProof();
        }
        if (claimed[msg.sender]) {
            revert AlreadyClaimed();
        }
        claimed[msg.sender] = true;
        nextTokenId++;
        _mint(msg.sender, nextTokenId);
    }

    function tokenURI(uint256 tokenId)
        public
        view
        override
        returns (string memory)
    {
        return _BaseURI;
    }

    // Admin

    function setMerkleRoot(bytes32 _merkleRoot) external onlyOwner {
        merkleRoot = _merkleRoot;
    }

    function withdrawAll() external {
        require(address(this).balance > 0, "Zero balance");
        (bool sent, ) = owner().call{value: address(this).balance}("");
        require(sent, "Failed to withdraw");
    }

    function withdrawAllERC20(IERC20 token) external {
        token.transfer(owner(), token.balanceOf(address(this)));
    }
}

