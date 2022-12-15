pragma solidity >=0.8.10 <0.9.0;

import "forge-std/Test.sol";

import "../src/DraupMembershipERC721.sol";

contract DraupMembershipERC721AllowListTest is Test {
    DraupMembershipERC721 public draupMembershipERC721;

    address private owner = vm.addr(uint256(keccak256(abi.encodePacked("owner"))));
    address private minter = vm.addr(uint256(keccak256(abi.encodePacked("minter"))));

    function setUp() public {
        draupMembershipERC721 = new DraupMembershipERC721();
        draupMembershipERC721.transferOwnership(owner);
        vm.deal(owner, 100 ether);
        vm.deal(minter, 100 ether);
    }

    function testMintBlocksInvalidMerkleProof() public {
        bytes32[] memory merkleProof = new bytes32[](3);
        merkleProof[0] = bytes32('med3af');
        merkleProof[1] = bytes32('med3af');
        merkleProof[2] = bytes32('med3af');
        vm.startPrank(minter);
        vm.expectRevert(abi.encodeWithSelector(DraupMembershipERC721.InvalidProof.selector));
        draupMembershipERC721.mint(merkleProof);
    }

    function testMintAllowsValidMerkleProof() public {
        bytes32[] memory merkleProof = new bytes32[](3);
        merkleProof[0] = bytes32('med3af');
        merkleProof[1] = bytes32('med3af');
        merkleProof[2] = bytes32('med3af');
        vm.startPrank(minter);
        vm.expectRevert(abi.encodeWithSelector(DraupMembershipERC721.InvalidProof.selector));
        draupMembershipERC721.mint(merkleProof);
    }


}