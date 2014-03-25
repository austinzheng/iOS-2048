iOS-2048
================

iOS drop-in library presenting a clean-room Objective-C implementation of the game 2048.

Instructions
------------
The included sample app demonstrates the game. Simply tap the button to play.

Create a new instance of the view controller using the provided factory method, and present it. Or manually create and configure a view and model object, and bridge them using the provided protocol.

Features
--------
- 2048, the tile-matching game, but native for iOS
- Configure size of game board (NxN square) and winning threshold
- Configure custom cell and cell number colors
- Scoring system
- Pretty animations

Future Features
---------------
- Delegate for dismissing view controller
- API for informing parent of game status/victory state
- Better win/lose screens than UIAlertViews
- Swipe based controls
- Actual library (rather than raw code hanging off a sample view controller)

2048 by Gabriele Cirulli (http://gabrielecirulli.com/). The original game can be found at http://gabrielecirulli.github.io/2048/, as can all relevant attributions. 2048 is inspired by an iOS game called "Threes", by Asher Vollmer.
