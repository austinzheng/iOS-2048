//
//  F3HGameModel.m
//  NumberTileGame
//
//  Created by Austin Zheng on 3/23/14.
//
//

#import "F3HGameModel.h"

typedef enum {
    F3HMergeTileModeEmpty = 0,
    F3HMergeTileModeNoAction,
    F3HMergeTileModeMove,
    F3HMergeTileModeSingleCombine,
    F3HMergeTileModeDoubleCombine
} F3HMergeTileMode;

@interface F3HGameModel ()

@property (nonatomic, weak) id<F3HGameModelProtocol> delegate;

@property (nonatomic, strong) NSMutableArray *gameState;

@property (nonatomic) NSUInteger dimension;
@property (nonatomic) NSUInteger winValue;

@end

@interface F3HTile : NSObject
@property (nonatomic) BOOL empty;
@property (nonatomic) NSUInteger value;
+ (instancetype)emptyTile;
@end

@interface F3HMergeTile : NSObject
@property (nonatomic) F3HMergeTileMode mode;
@property (nonatomic) NSInteger originalIndexA;
@property (nonatomic) NSInteger originalIndexB;
@property (nonatomic) NSInteger value;
+ (instancetype)mergeTile;
@end

@interface F3HMoveOrder ()

+ (instancetype)singleMoveOrderWithSource:(NSInteger)source
                              destination:(NSInteger)destination
                                 newValue:(NSInteger)value;

+ (instancetype)doubleMoveOrderWithFirstSource:(NSInteger)source1
                                  secondSource:(NSInteger)source2
                                   destination:(NSInteger)destination
                                      newValue:(NSInteger)value;

@end

@implementation F3HGameModel

+ (instancetype)gameModelWithDimension:(NSUInteger)dimension
                              winValue:(NSUInteger)value
                              delegate:(id<F3HGameModelProtocol>)delegate {
    F3HGameModel *model = [F3HGameModel new];
    model.dimension = dimension;
    model.winValue = value;
    model.delegate = delegate;
    return model;
}

#pragma mark - Insertion API

- (void)insertAtRandomLocationTileWithValue:(NSUInteger)value {
    // Check if gameboard is full
    BOOL emptySpotFound = NO;
    for (NSInteger i=0; i<[self.gameState count]; i++) {
        if (((F3HTile *) self.gameState[i]).empty) {
            emptySpotFound = YES;
            break;
        }
    }
    if (!emptySpotFound) {
        // Board is full, we will never be able to insert a tile
        return;
    }
    // Yes, this could run forever. Given the size of any practical gameboard, I don't think it's likely.
    NSInteger row = 0;
    BOOL shouldExit = NO;
    while (YES) {
        row = arc4random_uniform(self.dimension);
        // Check if row has any empty spots in column
        for (NSInteger i=0; i<self.dimension; i++) {
            if ([self tileForIndexPath:[NSIndexPath indexPathForRow:row inSection:i]].empty) {
                shouldExit = YES;
                break;
            }
        }
        if (shouldExit) {
            break;
        }
    }
    NSInteger column = 0;
    shouldExit = NO;
    while (YES) {
        column = arc4random_uniform(self.dimension);
        if ([self tileForIndexPath:[NSIndexPath indexPathForRow:row inSection:column]].empty) {
            shouldExit = YES;
            break;
        }
        if (shouldExit) {
            break;
        }
    }
    [self insertTileWithValue:value atIndexPath:[NSIndexPath indexPathForRow:row inSection:column]];
}

// Insert a tile (used by the game to add new tiles to the board)
- (void)insertTileWithValue:(NSUInteger)value
                atIndexPath:(NSIndexPath *)path {
    if (![self tileForIndexPath:path].empty) {
        return;
    }
    F3HTile *tile = [self tileForIndexPath:path];
    tile.empty = NO;
    tile.value = value;
    [self.delegate insertTileAtIndexPath:path value:value];
}


#pragma mark - Movement API

// Perform a user-initiated move in one of four directions
- (BOOL)performMoveInDirection:(F3HMoveDirection)direction {
    switch (direction) {
        case F3HMoveDirectionUp:
            return [self performUpMove];
        case F3HMoveDirectionDown:
            return [self performDownMove];
        case F3HMoveDirectionLeft:
            return [self performLeftMove];
        case F3HMoveDirectionRight:
            return [self performRightMove];
    }
}

- (BOOL)performUpMove {
    BOOL atLeastOneMove = NO;
    
    // Examine each column, left to right ([]-->[]-->[])
    for (NSInteger column = 0; column<self.dimension; column++) {
        NSMutableArray *thisColumnTiles = [NSMutableArray arrayWithCapacity:self.dimension];
        for (NSInteger row = 0; row<self.dimension; row++) {
            [thisColumnTiles addObject:[self tileForIndexPath:[NSIndexPath indexPathForRow:row inSection:column]]];
        }
        NSArray *ordersArray = [self mergeGroup:thisColumnTiles];
        if ([ordersArray count] > 0) {
            atLeastOneMove = YES;
            for (NSInteger i=0; i<[ordersArray count]; i++) {
                F3HMoveOrder *order = ordersArray[i];
                if (order.doubleMove) {
                    // Update internal model
                    NSIndexPath *source1Path = [NSIndexPath indexPathForRow:order.source1 inSection:column];
                    NSIndexPath *source2Path = [NSIndexPath indexPathForRow:order.source2 inSection:column];
                    NSIndexPath *destinationPath = [NSIndexPath indexPathForRow:order.destination inSection:column];
                    
                    F3HTile *source1Tile = [self tileForIndexPath:source1Path];
                    source1Tile.empty = YES;
                    F3HTile *source2Tile = [self tileForIndexPath:source2Path];
                    source2Tile.empty = YES;
                    F3HTile *destinationTile = [self tileForIndexPath:destinationPath];
                    destinationTile.empty = NO;
                    destinationTile.value = order.value;
                    
                    // Update delegate
                    [self.delegate moveTileOne:source1Path
                                       tileTwo:source2Path
                                   toIndexPath:destinationPath
                                      newValue:order.value];
                }
                else {
                    // Update internal model
                    NSIndexPath *sourcePath = [NSIndexPath indexPathForRow:order.source1 inSection:column];
                    NSIndexPath *destinationPath = [NSIndexPath indexPathForRow:order.destination inSection:column];
                    
                    F3HTile *sourceTile = [self tileForIndexPath:sourcePath];
                    sourceTile.empty = YES;
                    F3HTile *destinationTile = [self tileForIndexPath:destinationPath];
                    destinationTile.empty = NO;
                    destinationTile.value = order.value;
                    
                    // Update delegate
                    [self.delegate moveTileFromIndexPath:sourcePath
                                             toIndexPath:destinationPath
                                                newValue:order.value];
                }
            }
        }
    }
    return atLeastOneMove;
}

- (BOOL)performDownMove {
    BOOL atLeastOneMove = NO;
    
    // Examine each column, left to right ([]-->[]-->[])
    for (NSInteger column = 0; column<self.dimension; column++) {
        NSMutableArray *thisColumnTiles = [NSMutableArray arrayWithCapacity:self.dimension];
        for (NSInteger row = (self.dimension - 1); row >= 0; row--) {
            [thisColumnTiles addObject:[self tileForIndexPath:[NSIndexPath indexPathForRow:row inSection:column]]];
        }
        NSArray *ordersArray = [self mergeGroup:thisColumnTiles];
        if ([ordersArray count] > 0) {
            atLeastOneMove = YES;
            for (NSInteger i=0; i<[ordersArray count]; i++) {
                F3HMoveOrder *order = ordersArray[i];
                NSInteger dim = self.dimension - 1;
                if (order.doubleMove) {
                    // Update internal model
                    NSIndexPath *source1Path = [NSIndexPath indexPathForRow:(dim - order.source1) inSection:column];
                    NSIndexPath *source2Path = [NSIndexPath indexPathForRow:(dim - order.source2) inSection:column];
                    NSIndexPath *destinationPath = [NSIndexPath indexPathForRow:(dim - order.destination) inSection:column];
                    
                    F3HTile *source1Tile = [self tileForIndexPath:source1Path];
                    source1Tile.empty = YES;
                    F3HTile *source2Tile = [self tileForIndexPath:source2Path];
                    source2Tile.empty = YES;
                    F3HTile *destinationTile = [self tileForIndexPath:destinationPath];
                    destinationTile.empty = NO;
                    destinationTile.value = order.value;
                    
                    // Update delegate
                    [self.delegate moveTileOne:source1Path
                                       tileTwo:source2Path
                                   toIndexPath:destinationPath
                                      newValue:order.value];
                }
                else {
                    // Update internal model
                    NSIndexPath *sourcePath = [NSIndexPath indexPathForRow:(dim - order.source1) inSection:column];
                    NSIndexPath *destinationPath = [NSIndexPath indexPathForRow:(dim - order.destination) inSection:column];
                    
                    F3HTile *sourceTile = [self tileForIndexPath:sourcePath];
                    sourceTile.empty = YES;
                    F3HTile *destinationTile = [self tileForIndexPath:destinationPath];
                    destinationTile.empty = NO;
                    destinationTile.value = order.value;
                    
                    // Update delegate
                    [self.delegate moveTileFromIndexPath:sourcePath
                                             toIndexPath:destinationPath
                                                newValue:order.value];
                }
            }
        }
    }
    return atLeastOneMove;
}

- (BOOL)performLeftMove {
    BOOL atLeastOneMove = NO;
    
    // Examine each row, up to down ([TTT] --> [---] --> [____])
    for (NSInteger row = 0; row<self.dimension; row++) {
        NSMutableArray *thisRowTiles = [NSMutableArray arrayWithCapacity:self.dimension];
        for (NSInteger column = 0; column<self.dimension; column++) {
            [thisRowTiles addObject:[self tileForIndexPath:[NSIndexPath indexPathForRow:row inSection:column]]];
        }
        NSArray *ordersArray = [self mergeGroup:thisRowTiles];
        if ([ordersArray count] > 0) {
            atLeastOneMove = YES;
            for (NSInteger i=0; i<[ordersArray count]; i++) {
                F3HMoveOrder *order = ordersArray[i];
                if (order.doubleMove) {
                    // Update internal model
                    NSIndexPath *source1Path = [NSIndexPath indexPathForRow:row inSection:order.source1];
                    NSIndexPath *source2Path = [NSIndexPath indexPathForRow:row inSection:order.source2];
                    NSIndexPath *destinationPath = [NSIndexPath indexPathForRow:row inSection:order.destination];
                    
                    F3HTile *source1Tile = [self tileForIndexPath:source1Path];
                    source1Tile.empty = YES;
                    F3HTile *source2Tile = [self tileForIndexPath:source2Path];
                    source2Tile.empty = YES;
                    F3HTile *destinationTile = [self tileForIndexPath:destinationPath];
                    destinationTile.empty = NO;
                    destinationTile.value = order.value;
                    
                    // Update delegate
                    [self.delegate moveTileOne:source1Path
                                       tileTwo:source2Path
                                   toIndexPath:destinationPath
                                      newValue:order.value];
                }
                else {
                    // Update internal model
                    NSIndexPath *sourcePath = [NSIndexPath indexPathForRow:row inSection:order.source1];
                    NSIndexPath *destinationPath = [NSIndexPath indexPathForRow:row inSection:order.destination];
                    
                    F3HTile *sourceTile = [self tileForIndexPath:sourcePath];
                    sourceTile.empty = YES;
                    F3HTile *destinationTile = [self tileForIndexPath:destinationPath];
                    destinationTile.empty = NO;
                    destinationTile.value = order.value;
                    
                    // Update delegate
                    [self.delegate moveTileFromIndexPath:sourcePath
                                             toIndexPath:destinationPath
                                                newValue:order.value];
                }
            }
        }
    }
    return atLeastOneMove;
}

- (BOOL)performRightMove {
    BOOL atLeastOneMove = NO;
    
    // Examine each row, up to down ([TTT] --> [---] --> [____])
    for (NSInteger row = 0; row<self.dimension; row++) {
        NSMutableArray *thisRowTiles = [NSMutableArray arrayWithCapacity:self.dimension];
        for (NSInteger column = (self.dimension - 1); column >= 0; column--) {
            [thisRowTiles addObject:[self tileForIndexPath:[NSIndexPath indexPathForRow:row inSection:column]]];
        }
        NSArray *ordersArray = [self mergeGroup:thisRowTiles];
        if ([ordersArray count] > 0) {
            NSInteger dim = self.dimension - 1;
            atLeastOneMove = YES;
            for (NSInteger i=0; i<[ordersArray count]; i++) {
                F3HMoveOrder *order = ordersArray[i];
                if (order.doubleMove) {
                    // Update internal model
                    NSIndexPath *source1Path = [NSIndexPath indexPathForRow:row inSection:(dim - order.source1)];
                    NSIndexPath *source2Path = [NSIndexPath indexPathForRow:row inSection:(dim - order.source2)];
                    NSIndexPath *destinationPath = [NSIndexPath indexPathForRow:row inSection:(dim - order.destination)];
                    
                    F3HTile *source1Tile = [self tileForIndexPath:source1Path];
                    source1Tile.empty = YES;
                    F3HTile *source2Tile = [self tileForIndexPath:source2Path];
                    source2Tile.empty = YES;
                    F3HTile *destinationTile = [self tileForIndexPath:destinationPath];
                    destinationTile.empty = NO;
                    destinationTile.value = order.value;
                    
                    // Update delegate
                    [self.delegate moveTileOne:source1Path
                                       tileTwo:source2Path
                                   toIndexPath:destinationPath
                                      newValue:order.value];
                }
                else {
                    // Update internal model
                    NSIndexPath *sourcePath = [NSIndexPath indexPathForRow:row inSection:(dim - order.source1)];
                    NSIndexPath *destinationPath = [NSIndexPath indexPathForRow:row inSection:(dim - order.destination)];
                    
                    F3HTile *sourceTile = [self tileForIndexPath:sourcePath];
                    sourceTile.empty = YES;
                    F3HTile *destinationTile = [self tileForIndexPath:destinationPath];
                    destinationTile.empty = NO;
                    destinationTile.value = order.value;
                    
                    // Update delegate
                    [self.delegate moveTileFromIndexPath:sourcePath
                                             toIndexPath:destinationPath
                                                newValue:order.value];
                }
            }
        }
    }
    return atLeastOneMove;
}


#pragma mark - Game State API

- (BOOL)userHasLost {
    for (NSInteger i=0; i<[self.gameState count]; i++) {
        if (((F3HTile *) self.gameState[i]).empty) {
            // Gameboard must be full for the user to lose
            return NO;
        }
    }
    // This is a stupid algorithm, but given how small the game board is it should work just fine
    // Every tile compares its value to that of the tiles to the right and below (if possible)
    for (NSInteger i=0; i<self.dimension; i++) {
        for (NSInteger j=0; j<self.dimension; j++) {
            F3HTile *tile = [self tileForIndexPath:[NSIndexPath indexPathForRow:i inSection:j]];
            if (j != (self.dimension - 1)
                && tile.value == [self tileForIndexPath:[NSIndexPath indexPathForRow:i inSection:j+1]].value) {
                return NO;
            }
            if (i != (self.dimension - 1)
                && tile.value == [self tileForIndexPath:[NSIndexPath indexPathForRow:i+1 inSection:j]].value) {
                return NO;
            }
        }
    }
    return YES;
}

- (BOOL)userHasWon {
    for (NSInteger i=0; i<[self.gameState count]; i++) {
        if (((F3HTile *) self.gameState[i]).value == self.winValue) {
            return YES;
        }
    }
    return NO;
}


#pragma mark - Private Methods

- (F3HTile *)tileForIndexPath:(NSIndexPath *)indexPath {
    NSInteger idx = (indexPath.row*self.dimension + indexPath.section);
    if (idx >= [self.gameState count]) {
        return nil;
    }
    return self.gameState[idx];
}

- (void)setTile:(F3HTile *)tile forIndexPath:(NSIndexPath *)indexPath {
    NSInteger idx = (indexPath.row*self.dimension + indexPath.section);
    if (!tile || idx >= [self.gameState count]) {
        return;
    }
    self.gameState[idx] = tile;
}

- (NSMutableArray *)gameState {
    if (!_gameState) {
        _gameState = [NSMutableArray array];
        for (NSInteger i=0; i<(self.dimension * self.dimension); i++) {
            [_gameState addObject:[F3HTile emptyTile]];
        }
    }
    return _gameState;
}

// Merge some items to the left
// "Group" is an array of tile objects
- (NSArray *)mergeGroup:(NSArray *)group {
    NSInteger ctr = 0;
    // STEP 1: collapse all tiles (remove any interstital space)
    // e.g. |[2] [ ] [ ] [4]| becomes [[2] [4]|
    // At this point, tiles either move or don't move, and their value remains the same
    NSMutableArray *stack1 = [NSMutableArray array];
    for (NSInteger i=0; i<self.dimension; i++) {
        F3HTile *tile = group[i];
        if (tile.empty) {
            // Don't do anything with empty tiles
            continue;
        }
        F3HMergeTile *mergeTile = [F3HMergeTile mergeTile];
        mergeTile.originalIndexA = i;
        mergeTile.value = tile.value;
        if (i == ctr) {
            mergeTile.mode = F3HMergeTileModeNoAction;
        }
        else {
            mergeTile.mode = F3HMergeTileModeMove;
        }
        [stack1 addObject:mergeTile];
        ctr++;
    }
    if ([stack1 count] == 0) {
        // Nothing to do, no tiles in this group
        return nil;
    }
    else if ([stack1 count] == 1) {
        // Only one tile in this group. Either it moved, or it didn't.
        if (((F3HMergeTile *)stack1[0]).mode == F3HMergeTileModeMove) {
            // Tile moved. Add one move order.
            F3HMergeTile *mTile = (F3HMergeTile *)stack1[0];
            return @[[F3HMoveOrder singleMoveOrderWithSource:mTile.originalIndexA
                                                 destination:0
                                                    newValue:mTile.value]];
        }
        else {
            return nil;
        }
    }
    
    // STEP 2: starting from the left, and moving to the right, collapse tiles
    // e.g. |[8][8][4][2][2]| should become |[16][4][4]|
    // e.g. |[2][2][2]| should become |[4][2]|
    // At this point, tiles may become the subject of a single or double merge
    ctr = 0;
    BOOL priorMergeHasHappened = NO;
    NSMutableArray *stack2 = [NSMutableArray array];
    while (ctr < ([stack1 count] - 1)) {
        F3HMergeTile *t1 = (F3HMergeTile *)stack1[ctr];
        F3HMergeTile *t2 = (F3HMergeTile *)stack1[ctr+1];
        if (t1.value == t2.value) {
            // First: update t1 and t2's modes
            NSAssert(t1.mode != F3HMergeTileModeSingleCombine && t2.mode != F3HMergeTileModeSingleCombine
                     && t1.mode != F3HMergeTileModeDoubleCombine && t2.mode != F3HMergeTileModeDoubleCombine,
                     @"Should not be able to get in a state where already-combined tiles are recombined");
            
            // Merge the two
            if (t1.mode == F3HMergeTileModeNoAction && !priorMergeHasHappened) {
                priorMergeHasHappened = YES;
                // t1 didn't move, but t2 merged onto t1.
                F3HMergeTile *newT = [F3HMergeTile mergeTile];
                newT.mode = F3HMergeTileModeSingleCombine;
                newT.originalIndexA = t2.originalIndexA;
                newT.value = t1.value * 2;
                [stack2 addObject:newT];
            }
            else {
                // t1 moved earlier.
                F3HMergeTile *newT = [F3HMergeTile mergeTile];
                newT.mode = F3HMergeTileModeDoubleCombine;
                newT.originalIndexA = t1.originalIndexA;
                newT.originalIndexB = t2.originalIndexA;
                newT.value = t1.value * 2;
                [stack2 addObject:newT];
            }
            ctr += 2;
        }
        else {
            // t1 is pushed onto stack2, as either a move or a no-op. The pointer is incremented
            [stack2 addObject:t1];
            if ([stack2 count] - 1 != ctr) {
                t1.mode = F3HMergeTileModeMove;
            }
            ctr++;
        }
        // Addendum:
        if (ctr == [stack1 count] - 1) {
            // We're at the end of stack1, and need to add t2 as well as t1.
            F3HMergeTile *item = stack1[ctr];
            [stack2 addObject:item];
            if ([stack2 count] - 1 != ctr) {
                item.mode = F3HMergeTileModeMove;
            }
        }
    }
    
    // STEP 3: create move orders for each mergeTile that did change this round
    NSMutableArray *stack3 = [NSMutableArray new];
    for (NSInteger i=0; i<[stack2 count]; i++) {
        F3HMergeTile *mTile = stack2[i];
        switch (mTile.mode) {
            case F3HMergeTileModeEmpty:
            case F3HMergeTileModeNoAction:
                continue;
            case F3HMergeTileModeMove:
            case F3HMergeTileModeSingleCombine:
                // Single combine
                [stack3 addObject:[F3HMoveOrder singleMoveOrderWithSource:mTile.originalIndexA
                                                              destination:i
                                                                 newValue:mTile.value]];
                break;
            case F3HMergeTileModeDoubleCombine:
                // Double combine
                [stack3 addObject:[F3HMoveOrder doubleMoveOrderWithFirstSource:mTile.originalIndexA
                                                                  secondSource:mTile.originalIndexB
                                                                   destination:i
                                                                      newValue:mTile.value]];
                break;
        }
    }
    // Return the finalized array
    return [NSArray arrayWithArray:stack3];
}

@end


#pragma mark - F3HMergeTile

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
    return [NSString stringWithFormat:@"MergeTile (mode: %@, source1: %d, source2: %d, value: %d)",
            modeStr, self.originalIndexA, self.originalIndexB, self.value];
}

@end


#pragma mark - F3HMoveOrder

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
        return [NSString stringWithFormat:@"MoveOrder (double, source1: %d, source2: %d, destination: %d, value: %d)",
                self.source1, self.source2, self.destination, self.value];
    }
    return [NSString stringWithFormat:@"MoveOrder (single, source: %d, destination: %d, value: %d)",
            self.source1, self.destination, self.value];
}

@end


#pragma mark - F3HTile

// Helper class
@implementation F3HTile

+ (instancetype)emptyTile {
    F3HTile *tile = [[self class] new];
    tile.empty = YES;
    tile.value = 0;
    return tile;
}

- (NSString *)description {
    if (self.empty) {
        return @"Tile (empty)";
    }
    return [NSString stringWithFormat:@"Tile (value: %d)", self.value];
}

@end
