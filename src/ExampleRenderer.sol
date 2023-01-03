// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import {IRenderer} from "./IRenderer.sol";
import {Strings} from "openzeppelin-contracts/contracts/utils/Strings.sol";


contract ExampleRenderer is IRenderer {
    function tokenURI(uint256 tokenId) external pure override returns (string memory) {
        return string(abi.encodePacked("https://www.example.com/", Strings.toString(tokenId), ".json"));
    }
}

