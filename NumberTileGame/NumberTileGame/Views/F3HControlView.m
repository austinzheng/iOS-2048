//
//  F3HControlView.m
//  NumberTileGame
//
//  Created by Austin Zheng on 3/25/14.
//
//

#import "F3HControlView.h"

#define DEFAULT_FRAME_SMALL     CGRectMake(0, 0, 230, 30)
#define DEFAULT_FRAME_LARGE     CGRectMake(0, 0, 230, 140)

@interface F3HControlView ()
@property (nonatomic) BOOL moveButtonsEnabled;
@property (nonatomic) BOOL exitButtonEnabled;
@property (nonatomic, weak) id<F3HControlViewProtocol> delegate;
@end

@implementation F3HControlView

+ (instancetype)controlViewWithCornerRadius:(CGFloat)radius
                            backgroundColor:(UIColor *)color
                            movementButtons:(BOOL)moveButtonsEnabled
                                 exitButton:(BOOL)exitButtonEnabled
                                   delegate:(id<F3HControlViewProtocol>)delegate {
    F3HControlView *view = [[[self class] alloc] initWithFrame:(moveButtonsEnabled ?
                                                                DEFAULT_FRAME_LARGE :
                                                                DEFAULT_FRAME_SMALL)];
    view.moveButtonsEnabled = moveButtonsEnabled;
    view.exitButtonEnabled = exitButtonEnabled;
    view.backgroundColor = color ?: [UIColor darkGrayColor];
    view.layer.cornerRadius = radius;
    view.delegate = delegate;
    [view setupSubviews];
    return view;
}

- (void)setupSubviews {
    if (self.moveButtonsEnabled) {
        // Large layout
        UIButton *upButton = [[UIButton alloc] initWithFrame:CGRectMake(90, 6, 50, 60)];
        upButton.layer.cornerRadius = 4;
        upButton.backgroundColor = [UIColor grayColor];
        upButton.showsTouchWhenHighlighted = YES;
        [upButton addTarget:self
                     action:@selector(upButtonTapped)
           forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:upButton];
        
        UIButton *downButton = [[UIButton alloc] initWithFrame:CGRectMake(90, 74, 50, 60)];
        downButton.layer.cornerRadius = 4;
        downButton.backgroundColor = [UIColor grayColor];
        downButton.showsTouchWhenHighlighted = YES;
        [downButton addTarget:self
                       action:@selector(downButtonTapped)
             forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:downButton];
        
        UIButton *leftButton = [[UIButton alloc] initWithFrame:CGRectMake(20, 62, 60, 50)];
        leftButton.layer.cornerRadius = 4;
        leftButton.backgroundColor = [UIColor grayColor];
        leftButton.showsTouchWhenHighlighted = YES;
        [leftButton addTarget:self
                       action:@selector(leftButtonTapped)
             forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:leftButton];
        
        UIButton *rightButton = [[UIButton alloc] initWithFrame:CGRectMake(150, 62, 60, 50)];
        rightButton.layer.cornerRadius = 4;
        rightButton.backgroundColor = [UIColor grayColor];
        rightButton.showsTouchWhenHighlighted = YES;
        [rightButton addTarget:self
                        action:@selector(rightButtonTapped)
              forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:rightButton];
        
        UIButton *resetButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 70, 30)];
        resetButton.titleLabel.textColor = [UIColor whiteColor];
        resetButton.titleLabel.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:14];
        resetButton.showsTouchWhenHighlighted = YES;
        [resetButton addTarget:self
                        action:@selector(resetButtonTapped)
              forControlEvents:UIControlEventTouchUpInside];
        [resetButton setTitle:@"RESET" forState:UIControlStateNormal];
        [self addSubview:resetButton];
        
        if (self.exitButtonEnabled) {
            UIButton *exitButton = [[UIButton alloc] initWithFrame:CGRectMake(160, 0, 70, 30)];
            exitButton.titleLabel.textColor = [UIColor whiteColor];
            exitButton.titleLabel.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:14];
            exitButton.showsTouchWhenHighlighted = YES;
            [exitButton setTitle:@"EXIT" forState:UIControlStateNormal];
            [exitButton addTarget:self
                           action:@selector(exitButtonTapped)
                 forControlEvents:UIControlEventTouchUpInside];
            [self addSubview:exitButton];
        }
    }
    else {
        // Small layout
        UIButton *resetButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 70, 30)];
        resetButton.titleLabel.textColor = [UIColor whiteColor];
        resetButton.titleLabel.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:14];
        resetButton.showsTouchWhenHighlighted = YES;
        [resetButton setTitle:@"RESET" forState:UIControlStateNormal];
        [resetButton addTarget:self
                        action:@selector(resetButtonTapped)
              forControlEvents:UIControlEventTouchUpInside];
        [resetButton setTitle:@"RESET" forState:UIControlStateNormal];
        [self addSubview:resetButton];
        
        if (self.exitButtonEnabled) {
            UIButton *exitButton = [[UIButton alloc] initWithFrame:CGRectMake(160, 0, 70, 30)];
            exitButton.titleLabel.textColor = [UIColor whiteColor];
            exitButton.titleLabel.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:14];
            exitButton.showsTouchWhenHighlighted = YES;
            [exitButton setTitle:@"EXIT" forState:UIControlStateNormal];
            [exitButton addTarget:self
                           action:@selector(exitButtonTapped)
                 forControlEvents:UIControlEventTouchUpInside];
            [self addSubview:exitButton];
        }
    }
}

- (void)upButtonTapped {
    [self.delegate upButtonTapped];
}

- (void)downButtonTapped {
    [self.delegate downButtonTapped];
}

- (void)leftButtonTapped {
    [self.delegate leftButtonTapped];
}

- (void)rightButtonTapped {
    [self.delegate rightButtonTapped];
}

- (void)resetButtonTapped {
    [self.delegate resetButtonTapped];
}

- (void)exitButtonTapped {
    [self.delegate exitButtonTapped];
}

@end
