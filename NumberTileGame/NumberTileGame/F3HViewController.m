//
//  F3HViewController.m
//  NumberTileGame
//
//  Created by Austin Zheng on 3/22/14.
//
//

#import "F3HViewController.h"

#import "F3HGameboardView.h"

@interface F3HViewController ()

@property (nonatomic, strong) F3HGameboardView *gameboard;

@property (nonatomic) BOOL moveFlag;

@end

@implementation F3HViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.moveFlag = NO;
	// Do any additional setup after loading the view, typically from a nib.
    
    // TEST
    F3HGameboardView *gameboard = [F3HGameboardView gameboardWithDimension:4
                                                                 cellWidth:50
                                                               cellPadding:6
                                                           backgroundColor:[UIColor blackColor]
                                                           foregroundColor:[UIColor darkGrayColor]];
    CGRect gameboardFrame = gameboard.frame;
    gameboardFrame.origin.x = 0.5*(self.view.bounds.size.width - gameboardFrame.size.width);
    gameboardFrame.origin.y = 0.5*(self.view.bounds.size.height - gameboardFrame.size.height);
    gameboard.frame = gameboardFrame;
    
    [self.view addSubview:gameboard];
    
    [gameboard insertTileAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]
                           withValue:2];
    [gameboard insertTileAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:2]
                           withValue:4];
    self.gameboard = gameboard;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)testButtonTapped:(id)sender {
    NSIndexPath *p1 = [NSIndexPath indexPathForRow:0 inSection:0];
    NSIndexPath *p2 = [NSIndexPath indexPathForRow:0 inSection:3];
    
    // Move a test tile back and forth
    if (self.moveFlag) {
        [self.gameboard moveTileAtIndexPath:p2 toIndexPath:p1 withValue:2];
    }
    else {
        [self.gameboard moveTileAtIndexPath:p1 toIndexPath:p2 withValue:1024];
    }
    self.moveFlag = !self.moveFlag;
}

@end
