iOS-2048
================

iOS drop-in library presenting a clean-room Objective-C/Cocoa implementation of the game 2048.

Screenshot
----------
![Screenshot](screenshots/ss1.png?raw=true)

Instructions
------------
The included sample app demonstrates the game. Simply tap the button to play. Swipe to move the tiles. For additional fun try tweaking the parameters in F3HViewController.

Create a new instance of the view controller using the provided factory method, and present it. Or manually create and configure a view and model object, and bridge them using F3HGameModelProtocol.

Features
--------
- 2048, the tile-matching game, but native for iOS
- Configure size of game board (NxN square) and winning threshold
- Configure custom cell and cell number colors
- Choose between button controls, swipe gesture controls, or both
- Scoring system
- API for informing parent of game status/victory state
- Pretty animations, all done without SpriteKit

Future Features
---------------
- Better win/lose screens than UIAlertViews
- Actual library (rather than raw code hanging off a sample view controller)

License
-------
(c) 2014 Austin Zheng. Released under the terms of the MIT license.

2048 by Gabriele Cirulli (http://gabrielecirulli.com/). The original game can be found at http://gabrielecirulli.github.io/2048/, as can all relevant attributions. 2048 is inspired by an iOS game called [Threes](http://asherv.com/threes/), by Asher Vollmer.
