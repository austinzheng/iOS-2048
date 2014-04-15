//
//  F3HMoveOrder.m
//  NumberTileGame
//
//  Created by Austin Zheng on 3/24/14.
//
//

#import "F3HMoveOrder.h"

@implementation F3HMoveOrder

+ (instancetype)singleMoveOrderWithSource:(NSInteger)source destination:(NSInteger)destination newValue:(NSInteger)value {
    F3HMoveOrder *order = [[self class] new];
    order.doubleMove = NO;
    order.source1 = source;
    order.destination = destination;
    order.value = value;
    return order;
}

+ (instancetype)doubleMoveOrderWithFirstSource:(NSInteger)source1
                                  secondSource:(NSInteger)source2
                                   destination:(NSInteger)destination
                                      newValue:(NSInteger)value {
    F3HMoveOrder *order = [[self class] new];
    order.doubleMove = YES;
    order.source1 = source1;
    order.source2 = source2;
    order.destination = destination;
    order.value = value;
    return order;
}

- (NSString *)description {
    if (self.doubleMove) {
        return [NSString stringWithFormat:@"MoveOrder (double, source1: %ld, source2: %ld, destination: %ld, value: %ld)",
                (long)self.source1,
                (long)self.source2,
                (long)self.destination,
                (long)self.value];
    }
    return [NSString stringWithFormat:@"MoveOrder (single, source: %ld, destination: %ld, value: %ld)",
            (long)self.source1,
            (long)self.destination,
            (long)self.value];
}

@end
