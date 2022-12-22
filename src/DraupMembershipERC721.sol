// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import "openzeppelin-contracts/contracts/access/Ownable.sol";
import "openzeppelin-contracts/contracts/token/ERC721/ERC721.sol";
import "openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";
import "openzeppelin-contracts/contracts/utils/cryptography/MerkleProof.sol";
import "openzeppelin-contracts/contracts/utils/Strings.sol";

contract DraupMembershipERC721 is ERC721, Ownable {
    uint256 public immutable MAX_SUPPLY;
    uint256 public immutable ROYALTY = 7500;
    uint256 public immutable MIN_HOLD_BLOCKS = 900_000;

    constructor(uint256 maxSupply) ERC721("Draup Membership", "DRAUP") {
        MAX_SUPPLY = maxSupply;
    }

    uint256 public nextTokenId;
    bytes32 public merkleRoot;
    string _BaseURI = "test";

    // Mapping to track who used their allowlist spot
    mapping(address => bool) private _claimed;

    // Mapping to track when tokens were last transferred
    mapping(uint256 => uint256) private _lastTransfer;

    error InvalidProof();
    error AlreadyClaimed();
    error LockupPeriodNotOver();

    function toBytes32(address addr) pure internal returns (bytes32) {
        return bytes32(uint256(uint160(addr)));
    }

    function mint(bytes32[] calldata merkleProof) public {
        bytes32 leaf = keccak256(bytes.concat(keccak256(abi.encode(msg.sender, 1))));
        if (!MerkleProof.verify(merkleProof, merkleRoot, leaf)) {
            revert InvalidProof();
        }
        if (_claimed[msg.sender]) {
            revert AlreadyClaimed();
        }
        _claimed[msg.sender] = true;
        nextTokenId++;
        _mint(msg.sender, nextTokenId);
    }

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 firstTokenId,
        uint256 batchSize
    ) internal virtual override {
        // assumes chain is past block 900_000
        if (block.number <= _lastTransfer[firstTokenId] + MIN_HOLD_BLOCKS) {
            revert LockupPeriodNotOver();
        }
        _lastTransfer[firstTokenId] = block.number;
        super._beforeTokenTransfer(from, to, firstTokenId, batchSize);
    }

    function tokenURI(uint256 tokenId)
        public
        view
        override
        returns (string memory)
    {
        return string(abi.encodePacked(_BaseURI, Strings.toString(tokenId)));
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

