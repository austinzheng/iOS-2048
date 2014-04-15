//
//  F3HTileAppearanceProvider.m
//  NumberTileGame
//
//  Created by Austin Zheng on 3/22/14.
//
//

#import "F3HTileAppearanceProvider.h"

@implementation F3HTileAppearanceProvider

- (UIColor *)tileColorForValue:(NSUInteger)value {
    switch (value) {
        case 2:
            return [UIColor colorWithRed:238./255. green:228./255. blue:218./255. alpha:1];
        case 4:
            return [UIColor colorWithRed:237./255. green:224./255. blue:200./255. alpha:1];
        case 8:
            return [UIColor colorWithRed:242./255. green:177./255. blue:121./255. alpha:1];
        case 16:
            return [UIColor colorWithRed:245./255. green:149./255. blue:99./255. alpha:1];
        case 32:
            return [UIColor colorWithRed:246./255. green:124./255. blue:95./255. alpha:1];
        case 64:
            return [UIColor colorWithRed:246./255. green:94./255. blue:59./255. alpha:1];
        case 128:
        case 256:
        case 512:
        case 1024:
        case 2048:
            return [UIColor colorWithRed:237./255. green:207./255. blue:114./255. alpha:1];
        default:
            return [UIColor whiteColor];
    }
}

- (UIColor *)numberColorForValue:(NSUInteger)value {
    switch (value) {
        case 2:
        case 4:
            return [UIColor colorWithRed:119./255. green:110./255. blue:101./255. alpha:1];
        default:
            return [UIColor whiteColor];
    }
}

- (UIFont *)fontForNumbers {
    return [UIFont fontWithName:@"HelveticaNeue-Bold" size:20];
}

@end
