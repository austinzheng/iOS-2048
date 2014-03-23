//
//  F3HTileView.h
//  NumberTileGame
//
//  Created by Austin Zheng on 3/22/14.
//
//

#import <UIKit/UIKit.h>

@interface F3HTileView : UIView

@property (nonatomic) NSInteger tileValue;

+ (instancetype)tileForPosition:(CGPoint)position
                     sideLength:(CGFloat)side
                          value:(NSUInteger)value;

@end
