//
//  F3HTileModel.m
//  NumberTileGame
//
//  Created by Austin Zheng on 3/24/14.
//
//

#import "F3HTileModel.h"

@implementation F3HTileModel

+ (instancetype)emptyTile {
    F3HTileModel *tile = [[self class] new];
    tile.empty = YES;
    tile.value = 0;
    return tile;
}

- (NSString *)description {
    if (self.empty) {
        return @"Tile (empty)";
    }
    return [NSString stringWithFormat:@"Tile (value: %lu)", (unsigned long)self.value];
}

@end
