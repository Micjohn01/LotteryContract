// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

contract LotteryContract {

    struct Round {
        uint256 ticketPrice;
        uint256 prizePool;
        address[] participants;
        bool finished;
        address winner;
    }

    mapping(uint256 => Round) public rounds;
    uint256 public currentRound;

    event RoundStarted(uint256 indexed roundId, uint256 ticketPrice);
    event TicketPurchased(uint256 indexed roundId, address buyer);
    event WinnerSelected(uint256 indexed roundId, address winner, uint256 prize);

    function startNewRound(uint256 _ticketPrice) public {
        require(currentRound == 0 || rounds[currentRound].finished, "Current round not finished");
        currentRound++;
        rounds[currentRound] = Round({
            ticketPrice: _ticketPrice,
            prizePool: 0,
            participants: new address[](0),
            finished: false,
            winner: address(0)
        });
        emit RoundStarted(currentRound, _ticketPrice);
    }

    function buyTicket() public payable {
        Round storage round = rounds[currentRound];
        require(!round.finished, "Round is finished");
        require(msg.value == round.ticketPrice, "Incorrect ticket price");

        round.participants.push(msg.sender);
        round.prizePool += msg.value;
        emit TicketPurchased(currentRound, msg.sender);
    }

   function selectWinner() public {
    Round storage round = rounds[currentRound];
    require(!round.finished, "Round already finished");
    require(round.participants.length > 0, "No participants");

    // Mark the round as finished before any external calls
    round.finished = true;

    // Generate a pseudo-random winner index
    uint256 winnerIndex = uint256(keccak256(abi.encodePacked(block.timestamp, block.difficulty, round.participants.length))) % round.participants.length;
    round.winner = round.participants[winnerIndex];

    // Transfer prize pool to the winner safely using call
    (bool success, ) = payable(round.winner).call{value: round.prizePool}("");
    require(success, "Transfer failed");

    // Emit the event after a successful transfer
    emit WinnerSelected(currentRound, round.winner, round.prizePool);
}


    function getCurrentRoundInfo() public view returns (uint256 ticketPrice, uint256 prizePool, uint256 participantCount, bool finished) {
        Round storage round = rounds[currentRound];
        return (round.ticketPrice, round.prizePool, round.participants.length, round.finished);
    }
}