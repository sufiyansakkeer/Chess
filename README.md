# Chess

A Flutter-based chess game application with full chess rules implementation and clean architecture. This application provides a complete chess experience with standard rules, special moves, and an intuitive user interface.

![Image](https://github.com/user-attachments/assets/44a7bf12-c1e5-4d0e-8aaf-4d1273f1828b) <!-- Replace with actual screenshot when available -->

## Features

- Complete chess game with standard rules
- Intuitive drag-and-drop interface
- Support for special moves (castling, en passant, pawn promotion)
- Turn management system
- Check and checkmate detection
- Game state tracking
- Game history recording
- Sound effects and feedback
- Clean, layered architecture for maintainability
- Material 3 Expressive design principles

## Getting Started

### Usage

- Tap on a piece to select it
- Available moves will be highlighted on the board
- Tap on a highlighted square to move the selected piece
- The app will enforce chess rules and handle turn management automatically

## Architecture and Logic Documentation

### Overview

This Flutter chess game follows a layered architecture, separating the domain logic, application logic, and presentation layers. This separation promotes maintainability, testability, and scalability. The architecture is inspired by clean architecture principles, ensuring that business rules are independent of UI and external frameworks.

### Application Flow

The chess game follows a well-defined flow from initialization to game completion:

1. **Game Initialization**

   - The application starts by initializing the `GameStateManager` which sets up the chess board with pieces in their starting positions
   - The initial turn is set to white
   - The UI renders the board and pieces using the `ChessBoard` and `SwitchableChessPiece` widgets

2. **Player Interaction**

   - Player taps on a piece of their color
   - The `GameBloc` or `GamePresenterBloc` handles the selection event
   - Valid moves for the selected piece are calculated by `MoveValidator` and highlighted on the board
   - Player taps on a highlighted square to move the piece

3. **Move Execution**

   - The `GameStateManager` validates the move
   - `MoveExecutor` handles the move execution, including special cases:
     - Castling: Moves both king and rook
     - En Passant: Captures the opponent's pawn
     - Pawn Promotion: Replaces pawn with selected piece type
   - The move is recorded in algebraic notation
   - Captured pieces are tracked

4. **Post-Move Processing**

   - The turn switches to the opponent
   - The system checks for:
     - Check: If the opponent's king is in check
     - Checkmate: If the opponent has no valid moves and their king is in check
     - Stalemate: If the opponent has no valid moves but their king is not in check
   - Game state is updated and UI is refreshed

5. **Game Completion**

   - When checkmate or stalemate is detected, the game is marked as over
   - In case of checkmate, the winner is determined
   - The UI displays the game result
   - Players can reset the game to start a new match

6. **Theme and Piece Style Management**
   - Players can toggle between light and dark themes
   - Chess pieces can be displayed with different styles based on user preferences

### State Management with BLoC Pattern

This application uses the BLoC (Business Logic Component) pattern for state management, which provides several advantages:

1. **Separation of Concerns**

   - Business logic is separated from the UI
   - Each BLoC handles a specific feature or component
   - UI components react to state changes without managing the logic

2. **Predictable State Transitions**

   - Events trigger state changes in a predictable manner
   - All state transitions are explicit and traceable
   - Easier debugging and testing

3. **Main BLoCs in the Application**

   - **GameBloc**: Manages the core game state

     - Handles piece selection, movement, and game rules
     - Processes events like `PositionSelected`, `PieceMoved`, and `GameReset`
     - Maintains state including board configuration, selected pieces, and valid moves

   - **ThemeBloc**: Manages UI theme settings

     - Handles theme mode (light/dark) changes
     - Controls chess piece design preferences
     - Responds to events like `ThemeToggled` and `PieceDesignChanged`

   - **GamePresenterBloc**: Coordinates between game logic and UI
     - Acts as a facade for the UI to interact with the game
     - Simplifies complex interactions between components
     - Provides a clean API for the presentation layer

4. **BLoC Implementation Pattern**

   - Each BLoC consists of three main components:
     - **Events**: Input triggers that the BLoC responds to
     - **State**: Immutable objects representing the current status
     - **BLoC**: The component that transforms events into states

5. **Benefits in the Chess Application**
   - Complex game logic is encapsulated and testable
   - UI updates automatically when game state changes
   - Multiple UI components can react to the same state changes
   - State transitions are logged and traceable for debugging

### Architectural Layers

#### Domain Layer

The domain layer contains the core business logic and entities of the chess game, independent of any UI or external dependencies.

- **Entities**: Represent the core business objects

  - `PieceEntity`: Base class for all chess pieces
  - Specific piece implementations: `King`, `Queen`, `Rook`, `Bishop`, `Knight`, and `Pawn`
  - `GameState`: Interface defining the contract for game state management

- **Value Objects**: Immutable objects representing simple concepts
  - `Position`: Represents a position on the chess board (row, column)
  - `PieceColor`: Enum representing piece colors (white, black)
  - `PieceType`: Enum representing piece types (king, queen, rook, etc.)

#### Application Layer

The application layer implements the use cases of the application and orchestrates the domain logic.

- **Game State Management**:

  - `GameStateManager`: Implements the `GameState` interface, managing the game board, piece movements, turn management, and game over conditions
  - `MoveValidator`: Validates chess moves according to standard rules
  - `MoveExecutor`: Executes valid moves and handles special cases

- **Services**:
  - `GameHistoryService`: Records and manages game history
  - `FeedbackService`: Provides user feedback
  - `SoundService`: Manages sound effects

#### Presentation Layer

The presentation layer is responsible for the UI and user interaction.

- **Pages**: Main screens of the application

  - `GamePage`: Main game screen

- **Presenters**: Handle UI logic and state

  - `GamePresenter`: Manages game UI state and user interactions

- **Widgets**: Reusable UI components

  - `ChessBoard`: Renders the chess board
  - `ChessPiece`: Renders individual chess pieces

- **Providers**: State management
  - Various providers for managing UI state

### Use Cases Documentation

#### 1. Game Initialization

**Description**: Sets up a new chess game with pieces in their starting positions.

**Implementation**:

- `GameStateManager.reset()`: Resets the game state
- `GameStateManager._initializeBoard()`: Places pieces in their starting positions
- `GameStateManager._initializeBackRow()`: Helper method to set up the back row of pieces

**Algorithm**:

1. Create an 8x8 board represented as a 2D array
2. Place pawns on the second and seventh ranks
3. Place other pieces on the first and eighth ranks
4. Set the current turn to white
5. Reset game state variables (game over, winner, etc.)

#### 2. Piece Selection and Move Highlighting

**Description**: When a player selects a piece, the valid moves for that piece are highlighted.

**Implementation**:

- `GameStateManager.getValidMovesForPiece()`: Returns valid moves for a piece
- `MoveValidator.getValidMovesForPiece()`: Validates moves based on chess rules

**Algorithm**:

1. Get the piece at the selected position
2. If the piece belongs to the current player, calculate its possible moves
3. Filter moves that would leave the king in check
4. Return the list of valid moves

#### 3. Piece Movement

**Description**: Moves a piece from one position to another, handling captures and special moves.

**Implementation**:

- `GameStateManager.movePiece()`: Main method for moving pieces
- `MoveExecutor.executeMove()`: Executes the move and handles special cases

**Algorithm**:

1. Validate that the move is legal
2. Execute the move, handling special cases (castling, en passant, promotion)
3. Update the game state (captured pieces, move history)
4. Switch the current turn
5. Check for game-ending conditions (checkmate, stalemate)
6. Notify listeners of the state change

#### 4. Check Detection

**Description**: Detects when a king is in check.

**Implementation**:

- `MoveValidator.isInCheck()`: Determines if a king is in check
- `MoveValidator.isSquareUnderAttack()`: Checks if a square is under attack

**Algorithm**:

1. Find the king's position on the board
2. For each opponent piece, calculate its possible moves
3. If any opponent piece can move to the king's position, the king is in check

#### 5. Checkmate Detection

**Description**: Detects when a player is in checkmate.

**Implementation**:

- `MoveValidator.isCheckmate()`: Determines if a player is in checkmate

**Algorithm**:

1. Check if the king is in check
2. For each piece of the player in check:
   a. Calculate all possible moves
   b. For each move, simulate the move and check if the king would still be in check
3. If no moves can get the king out of check, it's checkmate

#### 6. Stalemate Detection

**Description**: Detects when a game ends in stalemate.

**Implementation**:

- `MoveValidator.isStalemate()`: Determines if a player is in stalemate

**Algorithm**:

1. Check if the king is NOT in check
2. Check if the player has no legal moves
3. If both conditions are true, it's stalemate

#### 7. Special Move: Castling

**Description**: Implements the castling move where the king moves two squares toward a rook, and the rook moves to the square the king crossed.

**Implementation**:

- `MoveValidator.getPotentialCastlingMoves()`: Calculates potential castling moves
- `MoveValidator.isCastlingPathClear()`: Checks if the castling path is clear
- `MoveExecutor.executeMove()`: Handles the actual castling move

**Algorithm**:

1. Check if the king and rook have not moved
2. Check if the squares between the king and rook are empty
3. Check if the king is in check
4. Check if the king would pass through or end up in check
5. If all conditions are met, move both the king and rook

#### 8. Special Move: En Passant

**Description**: Implements the en passant capture, where a pawn can capture an opponent's pawn that has just moved two squares forward.

**Implementation**:

- `Pawn.getPossibleMoves()`: Includes en passant captures in possible moves
- `MoveExecutor.executeMove()`: Handles the actual en passant capture

**Algorithm**:

1. Track the en passant target square when a pawn moves two squares
2. When calculating moves for pawns, include the en passant capture if available
3. When executing an en passant capture, remove the captured pawn

#### 9. Special Move: Pawn Promotion

**Description**: Implements pawn promotion when a pawn reaches the opposite end of the board.

**Implementation**:

- `MoveExecutor.executeMove()`: Handles pawn promotion

**Algorithm**:

1. Detect when a pawn reaches the opposite end of the board
2. Allow the player to choose a piece type for promotion
3. Replace the pawn with the chosen piece type

#### 10. Game History Recording

**Description**: Records the history of moves in standard chess notation.

**Implementation**:

- `GameHistoryService`: Records and manages game history
- `MoveExecutor.executeMove()`: Generates move notation

**Algorithm**:

1. When a move is executed, generate the appropriate chess notation
2. Add the notation to the move history
3. Provide methods to access and display the move history

### Edge Cases and Error Handling

The chess application handles various edge cases and potential error conditions to ensure a smooth user experience:

#### 1. Invalid Piece Selection

**Scenario**: Player attempts to select an opponent's piece or an empty square.

**Handling**:

- The `GameBloc` checks if the selected position contains a piece of the current player's color
- If invalid, the selection is cleared and no moves are highlighted
- No error message is displayed to maintain a clean UI

#### 2. Invalid Move Attempt

**Scenario**: Player attempts to move a piece to an invalid square (not in the list of valid moves).

**Handling**:

- The `GameStateManager.movePiece()` method validates moves against the list of valid moves
- Invalid moves are rejected and return `false`
- The UI maintains the current selection, allowing the player to choose a valid move

#### 3. Check Situation

**Scenario**: A player's king is in check.

**Handling**:

- The `MoveValidator.isInCheck()` method detects check situations
- Only moves that get the king out of check are allowed
- The UI can highlight the king to indicate the check situation
- Logging records the check situation for debugging

#### 4. Pawn Promotion

**Scenario**: A pawn reaches the opposite end of the board.

**Handling**:

- The `Pawn.canPromote()` method detects when a pawn reaches the promotion rank
- The `GameBloc` sets the state to pawn promotion mode
- A promotion dialog is displayed to the player
- If no selection is made, the pawn is automatically promoted to a queen
- The promotion is executed through the `MoveExecutor`

#### 5. Castling Restrictions

**Scenario**: Player attempts to castle in invalid situations (king in check, pieces have moved, path is blocked or under attack).

**Handling**:

- `MoveValidator.getPotentialCastlingMoves()` checks basic castling conditions
- `MoveValidator.isCastlingPathClear()` ensures the path is not under attack
- `MoveValidator.wouldPutKingInCheck()` prevents castling through or into check
- Invalid castling moves are filtered out from the valid moves list

#### 6. En Passant Timing

**Scenario**: En passant capture is only valid immediately after an opponent's pawn makes a double move.

**Handling**:

- The `GameStateManager` tracks the en passant target square
- The target is reset after each move
- `MoveValidator` includes en passant captures only when valid
- `MoveExecutor` handles the special capture logic

#### 7. Game Over Detection

**Scenario**: Game ends due to checkmate or stalemate.

**Handling**:

- After each move, `GameStateManager` checks for checkmate and stalemate
- If detected, the game is marked as over and the winner (if any) is recorded
- The UI is updated to show the game result
- Reset functionality allows starting a new game

#### 8. Theme Provider Availability

**Scenario**: Theme provider might not be available in certain contexts.

**Handling**:

- The `SwitchableChessPiece` widget uses defensive programming
- Default values are provided when the theme provider is not available
- Try-catch blocks prevent crashes when accessing providers

#### 9. Piece Asset Loading

**Scenario**: SVG assets for chess pieces might fail to load.

**Handling**:

- The `_getPieceAsset()` method in `SwitchableChessPiece` provides consistent asset paths
- Error handling in the Flutter SVG package prevents crashes
- Fallback colors are used when custom piece designs are not available

### Algorithm Details

#### Move Validation Algorithm

The move validation algorithm is one of the most complex parts of the chess game. It ensures that all moves follow chess rules and handles special cases.

**Implementation**: `MoveValidator.getValidMovesForPiece()`

**Steps**:

1. Get the piece at the specified position
2. If the piece belongs to the current player, get its possible moves based on piece type:
   - For pawns: forward movement, diagonal captures, en passant
   - For knights: L-shaped movements
   - For bishops: diagonal movements
   - For rooks: horizontal and vertical movements
   - For queens: combination of bishop and rook movements
   - For kings: one square in any direction, plus potential castling
3. Filter out moves that would leave the king in check:
   - For each possible move, simulate the move on a temporary board
   - Check if the king would be in check after the move
   - If so, remove the move from the list
4. For castling moves, perform additional validation:
   - Check if the king and rook have not moved
   - Check if the squares between them are empty
   - Check if the king is currently in check
   - Check if the king would pass through or end up in check
5. Return the filtered list of valid moves

#### Check Detection Algorithm

**Implementation**: `MoveValidator.isInCheck()`

**Steps**:

1. Find the king's position on the board
2. For each opponent piece on the board:
   - Calculate its possible moves based on piece type
   - If any of these moves include the king's position, the king is in check
3. Return true if the king is in check, false otherwise

#### Checkmate Detection Algorithm

**Implementation**: `MoveValidator.isCheckmate()`

**Steps**:

1. Check if the king is in check
2. If not, return false (not checkmate)
3. For each piece of the player in check:
   - Calculate all valid moves for the piece
   - For each move, simulate the move and check if the king would still be in check
   - If any move gets the king out of check, return false (not checkmate)
4. If no moves can get the king out of check, return true (checkmate)

#### Stalemate Detection Algorithm

**Implementation**: `MoveValidator.isStalemate()`

**Steps**:

1. Check if the king is in check
2. If yes, return false (not stalemate)
3. Check if the player has any valid moves:
   - For each piece of the player:
     - Calculate all valid moves for the piece
     - If any valid moves exist, return false (not stalemate)
4. If the player has no valid moves and the king is not in check, return true (stalemate)

### UI Design Principles

The chess application follows Material 3 Expressive design principles, providing a modern and engaging user experience:

#### Material 3 Expressive Implementation

1. **Dynamic Color System**

   - The application uses Material 3's dynamic color system
   - Colors adapt based on the user's theme preference (light/dark)
   - Primary and secondary colors are used consistently for selection and highlighting

2. **Depth and Dimension**

   - Chess pieces feature subtle 3D effects with refined silhouettes
   - Selected pieces use elevation and shadows to create a sense of depth
   - Animations provide tactile feedback during interactions

3. **Chess Piece Design**

   - Pieces follow a tribal-inspired design language
   - SVG format ensures crisp rendering at any size
   - Special designs include:
     - The "queen clown" design for the white queen
     - Modern, recognizable bishop shape
     - Redesigned rook with 3D aesthetic

4. **Animation and Transitions**

   - Smooth animations for piece selection and movement
   - Scale and rotation effects provide visual feedback
   - Transitions between screens follow Material motion principles

5. **Responsive Layout**

   - The UI adapts to different screen sizes
   - Chess board maintains proportions while maximizing available space
   - Side panels for move history and captured pieces adjust based on available width

6. **Accessibility Considerations**

   - High contrast between board squares
   - Piece designs maintain recognizability
   - Interactive elements have appropriate touch targets

7. **Implementation Details**
   - The `SwitchableChessPiece` widget handles piece rendering with Material 3 styling
   - Theme settings are managed through the `ThemeBloc`
   - Consistent spacing and typography follow Material 3 guidelines

## Project Structure

```
lib/
├── application/
│   ├── utils/
│   │   └── chess_utils.dart
│   ├── feedback_service.dart
│   ├── game_history_service.dart
│   ├── game_state_manager.dart
│   ├── move_executor.dart
│   ├── move_validator.dart
│   └── sound_service.dart
├── domain/
│   ├── entities/
│   │   ├── pieces/
│   │   │   ├── bishop.dart
│   │   │   ├── king.dart
│   │   │   ├── knight.dart
│   │   │   ├── pawn.dart
│   │   │   ├── queen.dart
│   │   │   └── rook.dart
│   │   ├── game_history.dart
│   │   ├── game_state.dart
│   │   ├── movement_helper.dart
│   │   └── piece_entity.dart
│   └── value_objects/
│       ├── piece_color.dart
│       ├── piece_type.dart
│       └── position.dart
├── presentation/
│   ├── blocs/
│   │   ├── game/
│   │   │   ├── game_bloc.dart
│   │   │   ├── game_event.dart
│   │   │   └── game_state.dart
│   │   ├── theme/
│   │   │   ├── theme_bloc.dart
│   │   │   ├── theme_event.dart
│   │   │   └── theme_state.dart
│   │   └── game_presenter/
│   │       ├── game_presenter_bloc.dart
│   │       ├── game_presenter_event.dart
│   │       └── game_presenter_state.dart
│   ├── pages/
│   │   ├── game_page.dart
│   │   └── enhanced_game_page.dart
│   └── widgets/
│       ├── chess_board.dart
│       ├── switchable_chess_piece.dart
│       ├── move_history_and_captured_pieces.dart
│       └── [other widgets]
├── utils/
│   └── [utility classes]
└── main.dart
```

## Testing

The application includes comprehensive tests to ensure the correctness of the chess rules and game logic.

Run the tests with:

```bash
flutter test
```

### Test Categories:

1. **Unit Tests**: Test individual components and algorithms

   - Piece movement tests
   - Check detection tests
   - Checkmate and stalemate tests
   - Special moves tests

2. **Integration Tests**: Test the interaction between components

   - Game state management tests
   - Move execution tests

3. **UI Tests**: Test the user interface
   - Board rendering tests
   - Piece interaction tests

## Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add some amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Resources

For help getting started with Flutter development:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)
- [Flutter online documentation](https://docs.flutter.dev/)
