// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import {ERC721} from "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import {ERC2981} from "@openzeppelin/contracts/token/common/ERC2981.sol";
import {BitMaps} from "@openzeppelin/contracts/utils/structs/BitMaps.sol";
import {MerkleProof} from "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";
import {Ownable2Step} from "@openzeppelin/contracts/access/Ownable2Step.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

/// @title MilleniumNFT
/// @author Eric Abt
/// @notice NFT Collection than can be airdropped and staked and has a 2.5% royalty
contract MilleniumNFT is ERC721, ERC2981, Ownable2Step {
    uint256 constant MAX_SUPPLY = 1000;
    uint256 minted;

    bytes32 public immutable merkleRoot;
    BitMaps.BitMap private _airdropList;

    constructor(bytes32 _merkleRoot, address _owner) ERC721("Millenium NFT", "MILL") Ownable(_owner) {
        _setDefaultRoyalty(msg.sender, 250);
        merkleRoot = _merkleRoot;
    }

    function supportsInterface(bytes4 interfaceId) public view override(ERC721, ERC2981) returns (bool) {
        return super.supportsInterface(interfaceId);
    }

    /// @notice mint function
    /// @dev Explain to a developer any extra details
    /// @param tokenId Documents a parameter just like in doxygen (must be followed by parameter name)
    function mint(uint256 tokenId) external payable {
        require(minted < MAX_SUPPLY, "Reached max mints");
        require(msg.value >= 5 ether);

        minted++;
        _mint(msg.sender, tokenId);
    }

    /// @notice User can claim a token if one was alloted to them
    /// @dev used bitmap method
    /// @param proof calculated offchain
    /// @param tokenId item they wish to mint
    function claimAirDrop(bytes32[] calldata proof, uint256 tokenId) external payable {
        require(msg.value >= 1 ether);
        require(minted < MAX_SUPPLY, "Reached max mints");
        require(!BitMaps.get(_airdropList, tokenId), "Already claimed");

        _verifyProof(proof, tokenId, msg.sender);

        BitMaps.setTo(_airdropList, tokenId, true);

        minted++;

        _mint(msg.sender, tokenId);
    }

    /// @notice contract owner can get their eth
    function withdraw() external onlyOwner {
        (bool sent,) = address(this).call{value: address(this).balance}("");
        require(sent, "transfer failed");
    }

    /// @notice verifies proof
    /// @param proof calculated offchain
    /// @param tokenId item to be claimed
    /// @param addr potential owner of item
    function _verifyProof(bytes32[] memory proof, uint256 tokenId, address addr) private view {
        bytes32 leaf = keccak256(bytes.concat(keccak256(abi.encode(addr, tokenId))));
        require(MerkleProof.verify(proof, merkleRoot, leaf), "Invalid proof");
    }
}
