//
//  F3HNumberTileGameViewController.m
//  NumberTileGame
//
//  Created by Austin Zheng on 3/22/14.
//
//

#import "F3HNumberTileGameViewController.h"

#import "F3HGameboardView.h"
#import "F3HControlView.h"
#import "F3HScoreView.h"
#import "F3HGameModel.h"

#define ELEMENT_SPACING 10

@interface F3HNumberTileGameViewController () <F3HGameModelProtocol, F3HControlViewProtocol>

@property (nonatomic, strong) F3HGameboardView *gameboard;
@property (nonatomic, strong) F3HGameModel *model;
@property (nonatomic, strong) F3HScoreView *scoreView;
@property (nonatomic, strong) F3HControlView *controlView;

@property (nonatomic) BOOL useScoreView;
@property (nonatomic) BOOL useControlView;

@property (nonatomic) NSUInteger dimension;
@property (nonatomic) NSUInteger threshold;
@end

@implementation F3HNumberTileGameViewController

+ (instancetype)numberTileGameWithDimension:(NSUInteger)dimension
                               winThreshold:(NSUInteger)threshold
                            backgroundColor:(UIColor *)backgroundColor
                                scoreModule:(BOOL)scoreModuleEnabled
                             buttonControls:(BOOL)buttonControlsEnabled
                              swipeControls:(BOOL)swipeControlsEnabled {
    F3HNumberTileGameViewController *c = [[self class] new];
    c.dimension = dimension > 2 ? dimension : 2;
    c.threshold = threshold > 8 ? threshold : 8;
    c.useScoreView = scoreModuleEnabled;
    c.useControlView = buttonControlsEnabled;
    c.view.backgroundColor = backgroundColor ?: [UIColor whiteColor];
    if (swipeControlsEnabled) {
        [c setupSwipeControls];
    }
    return c;
}


#pragma mark - Controller Lifecycle

- (void)setupSwipeControls {
    UISwipeGestureRecognizer *upSwipe = [[UISwipeGestureRecognizer alloc] initWithTarget:self
                                                                                  action:@selector(upButtonTapped)];
    upSwipe.numberOfTouchesRequired = 1;
    upSwipe.direction = UISwipeGestureRecognizerDirectionUp;
    [self.view addGestureRecognizer:upSwipe];
    
    UISwipeGestureRecognizer *downSwipe = [[UISwipeGestureRecognizer alloc] initWithTarget:self
                                                                                    action:@selector(downButtonTapped)];
    downSwipe.numberOfTouchesRequired = 1;
    downSwipe.direction = UISwipeGestureRecognizerDirectionDown;
    [self.view addGestureRecognizer:downSwipe];
    
    UISwipeGestureRecognizer *leftSwipe = [[UISwipeGestureRecognizer alloc] initWithTarget:self
                                                                                    action:@selector(leftButtonTapped)];
    leftSwipe.numberOfTouchesRequired = 1;
    leftSwipe.direction = UISwipeGestureRecognizerDirectionLeft;
    [self.view addGestureRecognizer:leftSwipe];
    
    UISwipeGestureRecognizer *rightSwipe = [[UISwipeGestureRecognizer alloc] initWithTarget:self
                                                                                     action:@selector(rightButtonTapped)];
    rightSwipe.numberOfTouchesRequired = 1;
    rightSwipe.direction = UISwipeGestureRecognizerDirectionRight;
    [self.view addGestureRecognizer:rightSwipe];
}

- (void)setupGame {
    F3HScoreView *scoreView;
    F3HControlView *controlView;
    
    CGFloat totalHeight = 0;
    
    // Set up score view
    if (self.useScoreView) {
        scoreView = [F3HScoreView scoreViewWithCornerRadius:6
                                            backgroundColor:[UIColor darkGrayColor]
                                                  textColor:[UIColor whiteColor]
                                                   textFont:[UIFont fontWithName:@"HelveticaNeue-Bold" size:16]];
        totalHeight += (ELEMENT_SPACING + scoreView.bounds.size.height);
        self.scoreView = scoreView;
    }
    
    // Set up control view
    if (self.useControlView) {
        controlView = [F3HControlView controlViewWithCornerRadius:6
                                                  backgroundColor:[UIColor blackColor]
                                                  movementButtons:YES
                                                       exitButton:NO
                                                         delegate:self];
        totalHeight += (ELEMENT_SPACING + controlView.bounds.size.height);
        self.controlView = controlView;
    }
    
    // Create gameboard
    CGFloat padding = (self.dimension > 5) ? 3.0 : 6.0;
    CGFloat cellWidth = floorf((230 - padding*(self.dimension+1))/((float)self.dimension));
    if (cellWidth < 30) {
        cellWidth = 30;
    }
    F3HGameboardView *gameboard = [F3HGameboardView gameboardWithDimension:self.dimension
                                                                 cellWidth:cellWidth
                                                               cellPadding:padding
                                                              cornerRadius:6
                                                           backgroundColor:[UIColor blackColor]
                                                           foregroundColor:[UIColor darkGrayColor]];
    totalHeight += gameboard.bounds.size.height;
    
    // Calculate heights
    CGFloat currentTop = 0.5*(self.view.bounds.size.height - totalHeight);
    if (currentTop < 0) {
        currentTop = 0;
    }
    
    if (self.useScoreView) {
        CGRect scoreFrame = scoreView.frame;
        scoreFrame.origin.x = 0.5*(self.view.bounds.size.width - scoreFrame.size.width);
        scoreFrame.origin.y = currentTop;
        scoreView.frame = scoreFrame;
        [self.view addSubview:scoreView];
        currentTop += (scoreFrame.size.height + ELEMENT_SPACING);
    }
    
    CGRect gameboardFrame = gameboard.frame;
    gameboardFrame.origin.x = 0.5*(self.view.bounds.size.width - gameboardFrame.size.width);
    gameboardFrame.origin.y = currentTop;
    gameboard.frame = gameboardFrame;
    [self.view addSubview:gameboard];
    currentTop += (gameboardFrame.size.height + ELEMENT_SPACING);
    
    if (self.useControlView) {
        CGRect controlFrame = controlView.frame;
        controlFrame.origin.x = 0.5*(self.view.bounds.size.width - controlFrame.size.width);
        controlFrame.origin.y = currentTop;
        controlView.frame = controlFrame;
        [self.view addSubview:controlView];
    }
    
    self.gameboard = gameboard;
    
    // Create mode;
    F3HGameModel *model = [F3HGameModel gameModelWithDimension:self.dimension
                                                      winValue:self.threshold
                                                      delegate:self];
    [model insertAtRandomLocationTileWithValue:2];
    [model insertAtRandomLocationTileWithValue:2];
    self.model = model;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupGame];
}


#pragma mark - Private API

- (void)followUp {
    // This is the earliest point the user can win
    if ([self.model userHasWon]) {
        [self.delegate gameFinishedWithVictory:YES score:self.model.score];
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Victory!" message:@"You won!" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
    }
    else {
        NSInteger rand = arc4random_uniform(10);
        if (rand == 1) {
            [self.model insertAtRandomLocationTileWithValue:4];
        }
        else {
            [self.model insertAtRandomLocationTileWithValue:2];
        }
        // At this point, the user may lose
        if ([self.model userHasLost]) {
            [self.delegate gameFinishedWithVictory:NO score:self.model.score];
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Defeat!" message:@"You lost..." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alert show];
        }
    }
}


#pragma mark - Model Protocol

- (void)moveTileFromIndexPath:(NSIndexPath *)fromPath toIndexPath:(NSIndexPath *)toPath newValue:(NSUInteger)value {
    [self.gameboard moveTileAtIndexPath:fromPath toIndexPath:toPath withValue:value];
}

- (void)moveTileOne:(NSIndexPath *)startA tileTwo:(NSIndexPath *)startB toIndexPath:(NSIndexPath *)end newValue:(NSUInteger)value {
    [self.gameboard moveTileOne:startA tileTwo:startB toIndexPath:end withValue:value];
}

- (void)insertTileAtIndexPath:(NSIndexPath *)path value:(NSUInteger)value {
    [self.gameboard insertTileAtIndexPath:path withValue:value];
}

- (void)scoreChanged:(NSInteger)newScore {
    self.scoreView.score = newScore;
}


#pragma mark - Control View Protocol

- (void)upButtonTapped {
    [self.model performMoveInDirection:F3HMoveDirectionUp completionBlock:^(BOOL changed) {
        if (changed) [self followUp];
    }];
}

- (void)downButtonTapped {
    [self.model performMoveInDirection:F3HMoveDirectionDown completionBlock:^(BOOL changed) {
        if (changed) [self followUp];
    }];
}

- (void)leftButtonTapped {
    [self.model performMoveInDirection:F3HMoveDirectionLeft completionBlock:^(BOOL changed) {
        if (changed) [self followUp];
    }];
}

- (void)rightButtonTapped {
    [self.model performMoveInDirection:F3HMoveDirectionRight completionBlock:^(BOOL changed) {
        if (changed) [self followUp];
    }];
}

- (void)resetButtonTapped {
    [self.gameboard reset];
    [self.model reset];
    [self.model insertAtRandomLocationTileWithValue:2];
    [self.model insertAtRandomLocationTileWithValue:2];
}

- (void)exitButtonTapped {
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
