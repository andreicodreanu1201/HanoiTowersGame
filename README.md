# HanoiTowersGame
Overview
This is a 3D Towers of Hanoi game (made as a school project along some colleagues) implemented in Processing (Java-based) using the P3D renderer. The game features animations, user interface buttons, a disc selection menu, and instructional screens.

 Classes & Key Structures
Disc Class
Represents a single disc:

Attributes: diameter, height, color, and vertical offset (yOffset).

Method afiseaza(x, esteSelectat): Draws the disc at a given x position. Highlights it if selected.

Method drawCylinder(...): Renders the disc as a 3D cylinder.

 Global Variables
Includes:

tije: 3 pegs (arrays of discs).

backupTije, backupMutari: For saving and restoring game state.

discSelectat, tijaSelectata: Track which disc and peg are currently selected.

mutari: Number of moves.

numarDiscuri: Number of discs selected.

Various animation variables: animX, animY, etapaAnimatie (animation stage), vitezaAnimatie, etc.

UI flags: to control menus, help screen, game over screen.

Button Class
Represents a UI button:

display() draws it.

isMouseOver() checks if the mouse is over it.

Main Functions
setup()
Initializes the game, sets full-screen mode, and creates UI buttons.

initializeGame()
Resets the game state:

Clears all pegs.

Generates discs and places them on the first peg (if not in selection/instructions screen).

Disc colors vary by index.

draw()
The main game loop:

Displays different screens based on flags:

Disc selection menu (drawDiscSelectionScreen)

Instructions (drawInstructionsScreen)

Game scene: renders base, pegs, discs, animations, UI (drawUI)

Game Over screen (drawGameOverScreen)

Calls updateAnimatie() to handle animated moves.

Screen Functions
drawDiscSelectionScreen()
Displays a menu to choose number of discs (3–10), and Start / Instructions buttons.

drawInstructionsScreen()
Displays how to play the game (rules, controls), with buttons to go back to the main menu or continue to the game.

drawUI()
Renders move count, disc count, "Help" text, and in-game buttons (reset, menu).

drawGameOverScreen()
Shown when the game is completed:

Displays win message, total moves.

Buttons for restarting or returning to the menu.

Animation Handling
updateAnimatie()
Handles the animation logic for valid and invalid moves:

Stages: lift → move → drop (for valid and invalid separately).

Uses lerp() for smooth transitions.

finalizeazaMutare()
Called at the end of an animation:

Clears selection and resets state.

Checks for game completion if move was valid.

Gameplay Rules
Only the top disc of any peg can be selected.

You can move a disc to another peg only if it's empty or the top disc there is larger.

Invalid moves are automatically undone with animation.
