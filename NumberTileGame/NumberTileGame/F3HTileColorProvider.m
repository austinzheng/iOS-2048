//
//  F3HTileColorProvider.m
//  NumberTileGame
//
//  Created by Austin Zheng on 3/22/14.
//
//

#import "F3HTileColorProvider.h"

@implementation F3HTileColorProvider

- (UIColor *)tileColorForValue:(NSUInteger)value {
    switch (value) {
        case 1:
            return [UIColor whiteColor];
        case 2:
            return [UIColor lightGrayColor];
        case 4:
            return [UIColor yellowColor];
        case 8:
            return [UIColor orangeColor];
        default:
            return [UIColor redColor];
    }
}

- (UIColor *)numberColorForValue:(NSUInteger)value {
    switch (value) {
        case 1:
        case 2:
        case 4:
        case 8:
            return [UIColor blackColor];
        default:
            return [UIColor whiteColor];
    }
}

@end
