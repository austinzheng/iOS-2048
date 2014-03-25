//
//  F3HTileView.h
//  NumberTileGame
//
//  Created by Austin Zheng on 3/22/14.
//
//

#import <UIKit/UIKit.h>

@protocol F3HTileColorProviderProtocol;
@interface F3HTileView : UIView

@property (nonatomic) NSInteger tileValue;

@property (nonatomic, weak) id<F3HTileColorProviderProtocol>delegate;

+ (instancetype)tileForPosition:(CGPoint)position
                     sideLength:(CGFloat)side
                          value:(NSUInteger)value
                   cornerRadius:(CGFloat)cornerRadius;

@end
