// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import {Test, console} from "forge-std/Test.sol";
import {MilleniumNFT} from "../src/ecosystem1/MilleniumNFT.sol";
import {RewardToken} from "../src/ecosystem1/RewardToken.sol";
import {Stake} from "../src/ecosystem1/Stake.sol";

contract StakeTest is Test {
    MilleniumNFT public milleniumNFT;
    RewardToken public rewardToken;
    Stake public stake;

    mapping(address => bool) public bitmap;

    address internal owner;
    address internal user1;

    address public alice = address(0x1);

    function setUp() public {
        bytes32 merkleRoot = 0x897d6714686d83f84e94501e5d6f0f38c94b75381b88d1de3878b4f3d2d5014a;

        owner = address(this);
        user1 = address(1);

        vm.label(owner, "Owner");
        vm.label(user1, "User1");

        milleniumNFT = new MilleniumNFT(merkleRoot, owner);
        rewardToken = new RewardToken();
        stake = new Stake(address(rewardToken), address(milleniumNFT));
    }

    function testRoyalty() public {
        (address payee, uint256 amount) = milleniumNFT.royaltyInfo(0, 1 ether);

        assertEq(payee, owner);
        assertEq(amount, (1 ether * 250) / 10000);
    }

    function testStaking() public {
        // user can mint an NFT
        vm.prank(user1);
        vm.deal(user1, 5 ether);
        milleniumNFT.mint{value: 5 ether}(20);
        assertEq(milleniumNFT.ownerOf(20), user1);

        // user can deposit into staking contract. Staking contract is now the
        // owner of token but original owner is still approved in order to get token back
        vm.prank(user1);
        milleniumNFT.safeTransferFrom(user1, address(stake), 20);
        assertEq(milleniumNFT.ownerOf(20), address(stake));
        assertEq(milleniumNFT.getApproved(20), user1);

        // user can now withdraw reward tokens but only once per 24 hours
        vm.prank(user1);
        assertEq(rewardToken.balanceOf(user1), 0);
        vm.prank(user1);
        stake.getTokenRewards(20);
        assertEq(rewardToken.balanceOf(user1), 10 * 10 ** rewardToken.decimals());
        vm.expectRevert();
        stake.getTokenRewards(20);
        vm.warp(block.timestamp + 1 days);
        vm.prank(user1);
        stake.getTokenRewards(20);
        assertEq(rewardToken.balanceOf(user1), 20 * 10 ** rewardToken.decimals());

        // user can withdraw their nft
        vm.prank(user1);
        stake.withdrawNFT(20);
        assertEq(milleniumNFT.ownerOf(20), address(user1));
    }

    function testClaimAirDrop() public {
        bytes32[] memory proof = new bytes32[](3);
        proof[0] = 0x50bca9edd621e0f97582fa25f616d475cabe2fd783c8117900e5fed83ec22a7c;
        proof[1] = 0x8138140fea4d27ef447a72f4fcbc1ebb518cca612ea0d392b695ead7f8c99ae6;
        proof[2] = 0x9005e06090901cdd6ef7853ac407a641787c28a78cb6327999fc51219ba3c880;

        uint256 tokenId = 0;

        assertEq(milleniumNFT.balanceOf(alice), 0);

        vm.prank(alice);
        vm.deal(alice, 1 ether);
        milleniumNFT.claimAirDrop{value: 1 ether}(proof, tokenId);

        assertEq(milleniumNFT.balanceOf(alice), 1);
    }
}
