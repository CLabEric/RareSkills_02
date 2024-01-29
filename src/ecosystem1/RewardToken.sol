// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity 0.8.20;

import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

/// @title RewardToken
/// @author Eric Abt
/// @notice Simple token to be used as staking rewards
contract RewardToken is ERC20("StakingToken", "ST") {
    using SafeERC20 for ERC20;

    /// @notice mint function
    /// @param _to address receiving token
    /// @param _amount amount of tokens

    function mint(address _to, uint256 _amount) external {
        _mint(_to, _amount);
    }
}
