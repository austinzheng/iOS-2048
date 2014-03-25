//
//  F3HNumberTileGameViewController.h
//  NumberTileGame
//
//  Created by Austin Zheng on 3/22/14.
//
//

#import <UIKit/UIKit.h>

@interface F3HNumberTileGameViewController : UIViewController

+ (instancetype)numberTileGameWithDimension:(NSUInteger)dimension
                               winThreshold:(NSUInteger)threshold
                                scoreModule:(BOOL)scoreModuleEnabled
                             buttonControls:(BOOL)buttonControlsEnabled
                              swipeControls:(BOOL)swipeControlsEnabled;

@end
