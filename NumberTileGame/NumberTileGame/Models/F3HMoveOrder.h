//
//  F3HMoveOrder.h
//  NumberTileGame
//
//  Created by Austin Zheng on 3/24/14.
//
//

#import <Foundation/Foundation.h>

@interface F3HMoveOrder : NSObject

@property (nonatomic) NSInteger source1;
@property (nonatomic) NSInteger source2;
@property (nonatomic) NSInteger destination;
@property (nonatomic) BOOL doubleMove;
@property (nonatomic) NSInteger value;

+ (instancetype)singleMoveOrderWithSource:(NSInteger)source
                              destination:(NSInteger)destination
                                 newValue:(NSInteger)value;

+ (instancetype)doubleMoveOrderWithFirstSource:(NSInteger)source1
                                  secondSource:(NSInteger)source2
                                   destination:(NSInteger)destination
                                      newValue:(NSInteger)value;

@end
