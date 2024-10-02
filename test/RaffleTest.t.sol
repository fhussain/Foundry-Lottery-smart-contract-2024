//SPDX-LICENSE-IDENTIFIER:MIT

pragma solidity ^0.8.19;

import {Test} from "forge-std/Test.sol";
import {DeployRaffle} from "script/DeployRaffle.s.sol";
import {Raffle} from "src/Raffle.sol";
import {HelperConfig} from "script/HelperConfig.s.sol";

contract RaffleTest is Test {
    Raffle raffle;
    HelperConfig helperConfig;
    uint256 entranceFee;
    uint256 interval;
    address vrfCoordinator;
    bytes32 gasLane;
    uint256 subscriptionId;
    uint32 callBackGasLimit;

    address public PLAYER = makeAddr("Player");
    uint256 public constant STARTING_PLAYER_BALANCE = 10 ether;

    event RaffleEntered(address indexed player);
    event winnerPicked(address payable recent_winner);

    function setUp() external {
        DeployRaffle deployraffle = new DeployRaffle();
        (raffle, helperConfig) = deployraffle.deployContract();
        HelperConfig.NetworkConfig memory config = helperConfig.getConfig();
        entranceFee = config.entranceFee;
        interval = config.interval;
        vrfCoordinator = config.vrfCoordinator;
        gasLane = config.gasLane;
        subscriptionId = config.subscriptionId;
        callBackGasLimit = config.callBackGasLimit;
        vm.deal(PLAYER, STARTING_PLAYER_BALANCE);
    }

    function testRaffleStateInitialisesOpen() public view {
        assert(raffle.getRaffleState() == Raffle.RaffleState.Open);
    }

    function testEnufEntryFee() public {
        //Arrange
        vm.prank(PLAYER);
        //Act
        vm.expectRevert(Raffle.Raffle__SendMoreToEnterRaffle.selector);
        //Assert
        raffle.enterRaffle();
    }

    function testThePlayerIsStored() public {
        //Arrange
        vm.prank(PLAYER);
        //Act
        raffle.enterRaffle{value: entranceFee}();
        //Assert
        assert(raffle.getPlayerAddress(0) == PLAYER);
    }

    function testEventEmitsWhenRaffleEntered() public {
        //Arrange
        vm.prank(PLAYER);
        //Act
        //true becz 1 index paramter
        //false no 2nd indexed parameter
        //false no 3rd indexed parameter
        //false as no unindexed parameter
        //address of the contract
        //only 3 indexed parameters allowed
        vm.expectEmit(true, false, false, false, address(raffle));
        emit RaffleEntered(PLAYER);
        //assert
        raffle.enterRaffle{value: entranceFee}();
    }
}
