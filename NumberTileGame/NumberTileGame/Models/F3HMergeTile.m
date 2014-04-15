//
//  F3HMergeTile.m
//  NumberTileGame
//
//  Created by Austin Zheng on 3/24/14.
//
//

#import "F3HMergeTile.h"

@implementation F3HMergeTile

+ (instancetype)mergeTile {
    return [[self class] new];
}

- (NSString *)description {
    NSString *modeStr;
    switch (self.mode) {
        case F3HMergeTileModeEmpty:
            modeStr = @"Empty";
            break;
        case F3HMergeTileModeNoAction:
            modeStr = @"NoAction";
            break;
        case F3HMergeTileModeMove:
            modeStr = @"Move";
            break;
        case F3HMergeTileModeSingleCombine:
            modeStr = @"SingleCombine";
            break;
        case F3HMergeTileModeDoubleCombine:
            modeStr = @"DoubleCombine";
    }
    return [NSString stringWithFormat:@"MergeTile (mode: %@, source1: %ld, source2: %ld, value: %ld)",
            modeStr,
            (long)self.originalIndexA,
            (long)self.originalIndexB,
            (long)self.value];
}

@end
