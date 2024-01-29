// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

interface IPrimes {
    function balanceOf(address) external returns (uint256);
    function tokenOfOwnerByIndex(address, uint256) external returns (uint256);
}

/// @title GetPrimes
/// @author Eric Abt
/// @notice counts a holder's nfts that have a prime number for a tokenId
contract GetPrimes {
    IPrimes primes;

    constructor(address _primeNFT) {
        primes = IPrimes(_primeNFT);
    }

    /// @notice checks if a number is prime
    /// @dev 1 does not count as a prime number
    /// @param tokenId - id of a specific item
    /// @return bool
    function isPrime(uint256 tokenId) internal pure returns (bool) {
        if (tokenId == 1) {
            return false;
        }

        uint256 i = 2;

        for (i; i < tokenId; i++) {
            if (tokenId % i == 0) {
                return false;
            }
        }

        return true;
    }

    /// @notice external call to get the prime count for a given holder
    /// @param _sender - address of nft holder you want to count primes for
    /// @return uint256 - count of prime numbers
    function countPrimes(address _sender) external returns (uint256) {
        uint256 balance = primes.balanceOf(_sender);
        uint256 count;

        for (uint256 i; i < balance; i++) {
            uint256 tokenId = primes.tokenOfOwnerByIndex(_sender, i);
            if (isPrime(tokenId)) count++;
        }

        return count;
    }
}
