// SPDX-License-Identifier: MIT

pragma solidity ^0.8.7;
import "@chainlink/contracts/src/v0.8/interfaces/VRFCoordinatorV2Interface.sol";
import "@chainlink/contracts/src/v0.8/VRFConsumerBaseV2.sol";
import "@chainlink/contracts/src/v0.8/KeeperCompatible.sol";
contract Raffle is VRFConsumerBaseV2, KeeperCompatibleInterface{
    /** STATE VARIABLES */
    
    enum RaffleState{
        Open,
        Closed
    }
    RaffleState public s_raffleState;
    uint256 public immutable entranceFee;
     address public s_recentWinner;
     struct Winner{
        address winner;
        uint256 amountWon;
     }
   
    uint public lastTimeStamp;
    Winner [] private winnersLists;
    address payable[] private players;
    
     
  
/** ERROR LOGS */
       error Raffle__TransferFailed();
    error sendMore_ToEnterRaffle();
    error  Raffle_RaffleNotOpen();
    error   Raffle_upKeepNotNeeded();

/** EVENTS */
     event RaffleEnter(address indexed player);
     event RequestedRaffleWinner(uint256 indexed requestId);
     event WinnerPicked(address indexed player);

  
 
    /** Chainlink VRF Variables */ 
VRFCoordinatorV2Interface COORDINATOR;
  uint64 s_subscriptionId;
  address constant vrfCoordinator = 0x2Ca8E0C643bDe4C2E08ab1fA0da3401AdAD7734D;
  bytes32 constant keyHash = 0x79d3d8832d904592c0bf9818b621522c988bb8b0c05cdc3b15aea1b6e8db0c15;
  uint32 constant callbackGasLimit = 100000;
  uint16 constant requestConfirmations = 3;
  uint32 constant numWords =  1;
  uint256[] public s_randomWords;
  uint256 public s_requestId;
 

    
 
    constructor(
        uint256 _entranceFee,
       uint64 subscriptionId
        )
        VRFConsumerBaseV2(vrfCoordinator)
        {
        
      lastTimeStamp = block.timestamp;
        
        COORDINATOR = VRFCoordinatorV2Interface(vrfCoordinator);
         s_subscriptionId = subscriptionId;
        entranceFee = _entranceFee;
        s_raffleState = RaffleState.Open;
    }
function enterRaffle() external payable{
 
// Open,Closed a Winner
  if(s_raffleState != RaffleState.Open){
      revert Raffle_RaffleNotOpen();
  }
 
 
 //You can enter Raffle
  if(msg.value < entranceFee){
     revert sendMore_ToEnterRaffle();

  }

 
  
 players.push(payable(msg.sender));
 emit RaffleEnter(msg.sender);


}
 /**
     * @dev This is the function that the Chainlink Keeper nodes call
     * they look for `upkeepNeeded` to return True.
     * the following should be true for this to return true:
     * 1. The time interval has passed between raffle runs.
     * 2. The lottery is open.
     * 3. The contract has ETH.
     * 4. Implicity, your subscription is funded with LINK.
     */

   function checkUpkeep(
        bytes memory /* checkData */
    )
        public
        view
        override
        returns (
            bool upkeepNeeded,
            bytes memory /* performData */
        )
    {
 bool timePassed = ((block.timestamp - lastTimeStamp) > 5 minutes);
  bool isOpen =RaffleState.Open == s_raffleState;
  bool hasPlayers= players.length > 0;
  upkeepNeeded=(isOpen && hasPlayers && timePassed);
    return (upkeepNeeded, "0x0");
        }

      /**
     * @dev Once `checkUpkeep` is returning `true`, this function is called
     * and it kicks off a Chainlink VRF call to get a random winner.
     */   

 function performUpkeep(
        bytes calldata /* performData */
    ) external override {
            
         (bool upkeepNeeded, ) = checkUpkeep("");
        // require(upkeepNeeded, "Upkeep not needed");
        if (!upkeepNeeded) {
            revert Raffle_upKeepNotNeeded();
        }
         s_raffleState = RaffleState.Closed;
    
      
        uint256 requestId = COORDINATOR.requestRandomWords(
         keyHash,
        s_subscriptionId,
        requestConfirmations,
        callbackGasLimit,
        numWords
    );
        emit RequestedRaffleWinner(requestId);  
        

       }    
        
       
 /**
     * @dev This is the function that Chainlink VRF node
     * calls to send the money to the random winner.
     */

   function fulfillRandomWords(
        uint256, /* requestId */
        uint256[] memory randomWords
    ) internal override {
        // s_players size 10
        // randomNumber 202
        // 202 % 10 ? what's doesn't divide evenly into 202?
        // 20 * 10 = 200
        // 2
        // 202 % 10 = 2
        uint256 indexOfWinner = randomWords[0] % players.length;
        address payable recentWinner = players[indexOfWinner];
        s_recentWinner = recentWinner;
        (bool success, ) = recentWinner.call{value: address(this).balance}("");
        // require(success, "Transfer failed");
        if (!success) {
            revert Raffle__TransferFailed();
        }
        winnersLists.push(Winner(s_recentWinner,address(this).balance));
        players = new address payable[](0);
         s_raffleState = RaffleState.Open;
        emit WinnerPicked(recentWinner);
    }


     function getRaffleBalance () external view returns (uint256){
      return address(this).balance;
  }


  function getWinnersList() external  view returns (uint256){
      return winnersLists.length;
  }

  function getPlayersLength() external view returns(uint256){
      return players.length;
  }


}

