// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity 0.8.20;

import {IERC721} from "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";

interface IRewardToken {
    function mint(address, uint256) external;
    function decimals() external returns (uint8);
}

/// @title Stake
/// @author Eric Abt
/// @notice Users can stake an nft and get erc20 rewards every 24 hours
contract Stake {
    mapping(address depositor => uint48 lastWithdrawal) lastWithdrawal;
    mapping(uint256 tokenId => address depositor) depositors;

    IRewardToken rewardToken;
    IERC721 milleniumNFT;

    constructor(address _rewardToken, address _milleniumNFT) {
        rewardToken = IRewardToken(_rewardToken);
        milleniumNFT = IERC721(_milleniumNFT);
    }

    function onERC721Received(address operator, address from, uint256 tokenId, bytes calldata data)
        external
        returns (bytes4)
    {
        milleniumNFT.approve(from, tokenId);
        return IERC721Receiver.onERC721Received.selector;
    }

    /// @notice user can 'unstake' by withdrawing their nft
    /// @param _tokenId - id of staked item
    function withdrawNFT(uint256 _tokenId) external {
        milleniumNFT.transferFrom(address(this), msg.sender, _tokenId);
    }

    /// @notice If an item is staked user can withdraw 10 reward tokens every 24 hours
    /// @param _tokenId - id of staked item
    function getTokenRewards(uint256 _tokenId) external {
        require(milleniumNFT.ownerOf(_tokenId) == address(this), "that token is not staked");
        require(milleniumNFT.getApproved(_tokenId) == msg.sender, "You are not the staker of this item");

        uint256 lastTime = lastWithdrawal[msg.sender];
        require((block.timestamp - lastTime >= 1 days) || lastTime == 0, "Unable to withdraw yet");

        uint256 decimals = uint256(rewardToken.decimals());
        lastWithdrawal[msg.sender] = uint48(block.timestamp);
        rewardToken.mint(msg.sender, 10 * 10 ** decimals);
    }
}
