// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import {ERC721} from "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import {ERC721Enumerable} from "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";

/// @title PrimeNFT
/// @author Eric Abt
/// @notice Simple NFT any user can mint
contract PrimeNFT is ERC721Enumerable {
    constructor() ERC721("Prime NFT", "PRIME") {}

    uint256 constant MAX_SUPPLY = 20;

    /// @notice mints one item at a time until MAX_SUPPLY is reached
    function mint() external {
        uint256 totalSupply = totalSupply();
        require(totalSupply < MAX_SUPPLY, "Reached Max mints");
        _mint(msg.sender, totalSupply + 1);
    }
}
