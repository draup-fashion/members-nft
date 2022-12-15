// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import "solmate/tokens/ERC721.sol";

contract DraupMembershipERC721 is ERC721 {

    constructor() ERC721("Draup Membership", "DRAUP") {}

    string _BaseURI = "test";

    function mint(address to, uint256 tokenId) public {
        _mint(to, tokenId);
    }

    function tokenURI(uint256 tokenId)
        public
        view
        override
        returns (string memory)
    {
        return _BaseURI;
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

