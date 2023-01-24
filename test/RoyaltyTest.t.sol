pragma solidity >=0.8.10 <0.9.0;

import "forge-std/Test.sol";
import "forge-std/console.sol";
import "../src/DraupMembershipERC721.sol";

contract DraupMembershipERC721AllowListTest is Test {
    DraupMembershipERC721 public draupMembershipERC721;
    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);
    address private owner = vm.addr(uint256(keccak256(abi.encodePacked("owner"))));
    address private minter = vm.addr(uint256(keccak256(abi.encodePacked("minter"))));
    address private recipient = vm.addr(uint256(keccak256(abi.encodePacked("recipient"))));
    bytes32 private merkleRoot = hex'e58156f1fe47b87b38d2fc90dd2ed37c2ed80c4833b46ef37fd6c10b4f15fadd';
    bytes32[] private merkleProof = new bytes32[](3);

    function setUp() public {
        draupMembershipERC721 = new DraupMembershipERC721(10, 'https://assets.draup.xyz/member_pass/metadata/member_pass_');
        draupMembershipERC721.transferOwnership(owner);
        vm.deal(owner, 100 ether);
        vm.deal(minter, 100 ether);
        vm.prank(owner);
        draupMembershipERC721.setMerkleRoot(merkleRoot);
        merkleProof[0] = hex'61608fc4a22e50bb7145b85c74b673404fdd82a4b05c5f176f36a092209a204d';
        merkleProof[1] = hex'b83b0d782919b4ecc6cb4f744339823754ed3d3e980cdf8204194bfa6bab1de8';
        merkleProof[2] = hex'e1196e36db67e723e3b325b53c9f124eb38460ed3c1e0b6a7b501cf9478f6ab0';
        vm.prank(minter);
        draupMembershipERC721.mint(merkleProof);
    }

    function testRoyaltyOnLargeAmounts() public {
        (address a1, uint256 amount1) = draupMembershipERC721.royaltyInfo(1, 1000);
        assertEq(a1, address(draupMembershipERC721));
        assertEq(amount1, 75);
        (address a2, uint256 amount2) = draupMembershipERC721.royaltyInfo(1, 1_000_000);
        assertEq(a2, address(draupMembershipERC721));
        assertEq(amount2, 75_000);
    }


    function testRoyaltyOnSmallAmounts() public {
        (address a1, uint256 amount1) = draupMembershipERC721.royaltyInfo(1, 100);
        assertEq(a1, address(draupMembershipERC721));
        assertEq(amount1, 7);
    }

}