//
//  F3HMergeTile.h
//  NumberTileGame
//
//  Created by Austin Zheng on 3/24/14.
//
//

#import <Foundation/Foundation.h>

typedef enum {
    F3HMergeTileModeEmpty = 0,
    F3HMergeTileModeNoAction,
    F3HMergeTileModeMove,
    F3HMergeTileModeSingleCombine,
    F3HMergeTileModeDoubleCombine
} F3HMergeTileMode;

@interface F3HMergeTile : NSObject

@property (nonatomic) F3HMergeTileMode mode;
@property (nonatomic) NSInteger originalIndexA;
@property (nonatomic) NSInteger originalIndexB;
@property (nonatomic) NSInteger value;

+ (instancetype)mergeTile;

@end
