// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import {Test, console} from "forge-std/Test.sol";
import {PrimeNFT} from "../src/ecosystem2/PrimeNFT.sol";
import {GetPrimes} from "../src/ecosystem2/GetPrimes.sol";

contract StakeTest is Test {
    PrimeNFT public primeNFT;
    GetPrimes public getPrimes;

    address internal user1;

    function setUp() public {
        user1 = address(1);

        vm.label(user1, "User1");

        primeNFT = new PrimeNFT();
        getPrimes = new GetPrimes(address(primeNFT));
    }

    // token id    : 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20
    // prime count : 0 1 2 2 3 3 4 4 4 4  5  5  6  6   6  6  7  7 8  8
    function testCountPrimes() public {
        for (uint256 i; i < 20; i++) {
            vm.prank(user1);
            primeNFT.mint();
        }
        assertEq(primeNFT.balanceOf(user1), 20);
        uint256 primeCount = getPrimes.countPrimes(user1);
        assertEq(primeCount, 8);
    }
}
