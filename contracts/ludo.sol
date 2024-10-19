// SPDX-License-Identifier: MIT

pragma solidity ^0.8.27;

contract LudoGame {
    uint constant BOARD_SIZE = 52;
    uint constant HOME_SIZE = 6;
    uint constant TOTAL_PLAYERS = 4;
    uint constant TOKENS_PER_PLAYER = 4;

    struct Player {
        address playerAddress;
        bool hasJoined;
        uint8[4] tokens; // Position of 4 tokens on the board
    }

    Player[TOTAL_PLAYERS] public players;
    uint public currentPlayerIndex;
    bool public gameStarted;

    // Events
    event PlayerJoined(address player);
    event DiceRolled(address player, uint8 diceValue);
    event TokenMoved(address player, uint8 tokenIndex, uint8 newPosition);
    event PlayerWon(address player);

    // Modifiers
    modifier onlyCurrentPlayer() {
        require(players[currentPlayerIndex].playerAddress == msg.sender, "Not your turn!");
        _;
    }

    modifier gameInProgress() {
        require(gameStarted, "Game not started yet");
        _;
    }

    // Initialize the game
    constructor() {
        currentPlayerIndex = 0;
    }

    // Function to join the game
    function joinGame() external {
        require(!gameStarted, "Game already started");
        for (uint i = 0; i < TOTAL_PLAYERS; i++) {
            if (!players[i].hasJoined) {
                players[i].playerAddress = msg.sender;
                players[i].hasJoined = true;
                emit PlayerJoined(msg.sender);
                if (i == TOTAL_PLAYERS - 1) {
                    gameStarted = true; // Start the game when all players have joined
                }
                return;
            }
        }
        revert("All player slots are filled");
    }

    // Dice roll function (randomness in Solidity is limited, but for simplicity, we'll use block data)
    function rollDice() external onlyCurrentPlayer gameInProgress returns (uint8) {
        uint8 diceValue = uint8((block.timestamp + block.number) % 6 + 1); // Simple randomness
        emit DiceRolled(msg.sender, diceValue);
        return diceValue;
    }

    // Move token
    function moveToken(uint8 tokenIndex, uint8 diceValue) external onlyCurrentPlayer gameInProgress {
        require(tokenIndex < TOKENS_PER_PLAYER, "Invalid token index");
        uint8 currentPos = players[currentPlayerIndex].tokens[tokenIndex];
        require(currentPos < BOARD_SIZE + HOME_SIZE, "Token has already reached home");

        uint8 newPosition = currentPos + diceValue;
        if (newPosition > BOARD_SIZE) {
            newPosition = BOARD_SIZE; // Don't overshoot the board
        }

        players[currentPlayerIndex].tokens[tokenIndex] = newPosition;
        emit TokenMoved(msg.sender, tokenIndex, newPosition);

        // Check if all tokens are home
        if (allTokensHome(currentPlayerIndex)) {
            emit PlayerWon(msg.sender);
            gameStarted = false;
        } else {
            nextTurn();
        }
    }

    // Helper function to check if all tokens of a player have reached home
    function allTokensHome(uint playerIndex) internal view returns (bool) {
        for (uint8 i = 0; i < TOKENS_PER_PLAYER; i++) {
            if (players[playerIndex].tokens[i] < BOARD_SIZE + HOME_SIZE) {
                return false;
            }
        }
        return true;
    }

    // Function to move to the next player's turn
    function nextTurn() internal {
        currentPlayerIndex = (currentPlayerIndex + 1) % TOTAL_PLAYERS;
    }
}
