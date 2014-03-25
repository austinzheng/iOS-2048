//
//  F3HGameboardView.h
//  NumberTileGame
//
//  Created by Austin Zheng on 3/22/14.
//
//

#import <UIKit/UIKit.h>

@interface F3HGameboardView : UIView

+ (instancetype)gameboardWithDimension:(NSUInteger)dimension
                             cellWidth:(CGFloat)width
                           cellPadding:(CGFloat)padding
                          cornerRadius:(CGFloat)cornerRadius
                       backgroundColor:(UIColor *)backgroundColor
                       foregroundColor:(UIColor *)foregroundColor;

- (void)reset;

- (void)insertTileAtIndexPath:(NSIndexPath *)path
                    withValue:(NSUInteger)value;

- (void)moveTileOne:(NSIndexPath *)startA
            tileTwo:(NSIndexPath *)startB
        toIndexPath:(NSIndexPath *)end
          withValue:(NSUInteger)value;

- (void)moveTileAtIndexPath:(NSIndexPath *)start
                toIndexPath:(NSIndexPath *)end
                  withValue:(NSUInteger)value;

@end
