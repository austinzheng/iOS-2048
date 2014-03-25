//
//  F3HControlView.h
//  NumberTileGame
//
//  Created by Austin Zheng on 3/25/14.
//
//

#import <UIKit/UIKit.h>

@protocol F3HControlViewProtocol

- (void)upButtonTapped;
- (void)downButtonTapped;
- (void)leftButtonTapped;
- (void)rightButtonTapped;
- (void)resetButtonTapped;
- (void)exitButtonTapped;

@end

@interface F3HControlView : UIView

+ (instancetype)controlViewWithCornerRadius:(CGFloat)radius
                            backgroundColor:(UIColor *)color
                            movementButtons:(BOOL)moveButtonsEnabled
                                 exitButton:(BOOL)exitButtonEnabled
                                   delegate:(id<F3HControlViewProtocol>)delegate;

@end
