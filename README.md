# chess

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

## Architecture and Logic Documentation

### Overview

This Flutter chess game follows a layered architecture, separating the domain logic, application logic, and presentation layers. This separation promotes maintainability, testability, and scalability.

### Key Components

- **Domain Layer:** This layer contains the core business logic and entities of the chess game.
  - `lib/domain/entities/`: Defines the entities like `PieceEntity`, `King`, `Queen`, `Rook`, `Bishop`, `Knight`, and `Pawn`. These classes represent the pieces on the board and their properties, such as color, position, and type.
  - `lib/domain/value_objects/`: Defines value objects like `Position`, `PieceColor`, and `PieceType`. These classes represent simple data structures with no identity.
  - `lib/domain/entities/game_state.dart`: Defines the `GameState` interface, which outlines the contract for managing the game state.
- **Application Layer:** This layer implements the use cases of the application and orchestrates the domain logic.
  - `lib/application/game_state_impl.dart`: Implements the `GameState` interface. It manages the game board, piece movements, turn management, and game over conditions. It also handles special moves like castling and en passant.
- **Presentation Layer:** This layer is responsible for the UI and user interaction.
  - `lib/presentation/pages/game_page.dart`: Builds the UI for the chess game, including the chessboard and piece rendering.
  - `lib/presentation/presenters/game_presenter.dart`: Acts as a presenter, taking user input from the `GamePage` and interacting with the `GameState` to update the game. It also manages the UI state, such as selected pieces and valid moves.
  - `lib/presentation/widgets/`: Contains custom widgets like `ChessBoard` and `ChessPiece` for rendering the game.

### Game Logic

The core game logic is implemented in the `GameStateImpl` class. It manages the following:

- **Board Representation:** The chessboard is represented as a 2D list of `PieceEntity?`.
- **Piece Movement:** The `movePiece` method handles piece movements, including validation, special moves, and pawn promotion.
- **Turn Management:** The `currentTurn` property tracks the current player's turn.
- **Game Over Conditions:** The `isGameOver` property indicates whether the game is over, and the `winner` property indicates the winner (if any).
- **Valid Move Calculation:** The `getValidMovesForPiece` method calculates the valid moves for a given piece, taking into account the piece's type, position, and the current board state. It also checks for checks, checkmates, and stalemates.

### Interactions

The `GamePage` interacts with the `GamePresenter` to handle user input, such as piece selections and move attempts. The `GamePresenter` then interacts with the `GameStateImpl` to update the game state. The `GameStateImpl` notifies the `GamePresenter` of any changes, which in turn updates the UI.

This architecture ensures a clear separation of concerns, making the codebase easier to understand, maintain, and test.
