//
//  F3HViewController.m
//  NumberTileGame
//
//  Created by Austin Zheng on 3/22/14.
//
//

#import "F3HViewController.h"

#import "F3HGameboardView.h"
#import "F3HGameModel.h"

@interface F3HViewController () <F3HGameModelProtocol>

@property (nonatomic, strong) F3HGameboardView *gameboard;
@property (nonatomic, strong) F3HGameModel *model;

@property (nonatomic) BOOL moveFlag;

@end

@implementation F3HViewController

- (void)viewDidLoad {
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
    
//    [gameboard insertTileAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]
//                           withValue:2];
//    [gameboard insertTileAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:2]
//                           withValue:4];
    
    self.gameboard = gameboard;
    F3HGameModel *model = [F3HGameModel gameModelWithDimension:4 winValue:2048 delegate:self];
    
    [model insertTileWithValue:2 atIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
    [model insertTileWithValue:4 atIndexPath:[NSIndexPath indexPathForRow:1 inSection:2]];
    [model insertTileWithValue:4 atIndexPath:[NSIndexPath indexPathForRow:3 inSection:2]];
    
    self.model = model;
    
}

- (IBAction)upButtonTapped:(id)sender {
    [self.model performMoveInDirection:F3HMoveDirectionUp];
}

- (IBAction)downButtonTapped:(id)sender {
    [self.model performMoveInDirection:F3HMoveDirectionDown];
}

- (IBAction)leftButtonTapped:(id)sender {
    [self.model performMoveInDirection:F3HMoveDirectionLeft];
}

- (IBAction)rightButtonTapped:(id)sender {
    [self.model performMoveInDirection:F3HMoveDirectionRight];
}


#pragma mark - Protocol

- (void)moveTileFromIndexPath:(NSIndexPath *)fromPath toIndexPath:(NSIndexPath *)toPath newValue:(NSUInteger)value {
    [self.gameboard moveTileAtIndexPath:fromPath toIndexPath:toPath withValue:value];
}

- (void)moveTileOne:(NSIndexPath *)startA tileTwo:(NSIndexPath *)startB toIndexPath:(NSIndexPath *)end newValue:(NSUInteger)value {
    [self.gameboard moveTileOne:startA tileTwo:startB toIndexPath:end withValue:value];
}

- (void)insertTileAtIndexPath:(NSIndexPath *)path value:(NSUInteger)value {
    [self.gameboard insertTileAtIndexPath:path withValue:value];
}

- (void)playerLost {
    // TODO
}

- (void)playerWonWithTile:(NSIndexPath *)tilePath {
    // TODO
}

#pragma mark - To delete

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
