//
//  F3HScoreView.h
//  NumberTileGame
//
//  Created by Austin Zheng on 3/25/14.
//
//

#import <UIKit/UIKit.h>

@interface F3HScoreView : UIView

@property (nonatomic) NSInteger score;

+ (instancetype)scoreViewWithCornerRadius:(CGFloat)radius
                          backgroundColor:(UIColor *)color
                                textColor:(UIColor *)textColor
                                 textFont:(UIFont *)textFont;

@end
