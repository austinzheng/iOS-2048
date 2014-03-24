//
//  F3HGameModel.m
//  NumberTileGame
//
//  Created by Austin Zheng on 3/23/14.
//
//

#import "F3HGameModel.h"

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

@interface F3HDestination : NSObject
@property (nonatomic) BOOL empty;
@property (nonatomic) BOOL finalValue;
@property (nonatomic) NSIndexPath *firstTileOrigin;
@property (nonatomic) NSIndexPath *secondTileOrigin;
@property (nonatomic) BOOL isDoubleMove;
+ (instancetype)emptyDestination;
- (void)reset;
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

// Perform a user-initiated move in one of four directions
- (void)performMoveInDirection:(F3HMoveDirection)direction {
    switch (direction) {
        case F3HMoveDirectionUp:
            [self performUpMove];
            break;
        case F3HMoveDirectionDown:
            [self performDownMove];
            break;
        case F3HMoveDirectionLeft:
            [self performLeftMove];
            break;
        case F3HMoveDirectionRight:
            [self performRightMove];
            break;
    }
}

- (void)performUpMove {
    NSMutableArray *destinationArray = [NSMutableArray array];
    for (NSInteger i=0; i<self.dimension; i++) {
        [destinationArray addObject:[F3HDestination emptyDestination]];
    }
    
    // Examine each column at a time
    for (NSInteger column=0; column<self.dimension; column++) {
        // Examine each row in a given column
        for (NSInteger row=1; row<self.dimension; row++) {
            // Get the current tile
            NSIndexPath *originalPath = [NSIndexPath indexPathForRow:row inSection:column];
            F3HTile *tile = [self tileForIndexPath:originalPath];
            if (tile.empty) continue;
            
            // Move the tile up as far as possible
            NSInteger newRow = row; // The new row to move the tile to, if any
            BOOL mergeNeeded = NO;
            for (NSInteger checkingRow = row-1; checkingRow >= 0; checkingRow--) {
                F3HTile *checkingTile = [self tileForIndexPath:[NSIndexPath indexPathForRow:checkingRow inSection:column]];
                if (checkingTile.empty) {
                    // The current space is empty. It may be a candidate for moving the tile
                    newRow = checkingRow;
                }
                else if (checkingTile.value == tile.value) {
                    mergeNeeded = YES;
                    // The current space is occupied, but has the same value. We must merge into this tile
                    newRow = checkingRow;
                    // Make a new destination object
                    F3HDestination *dest = destinationArray[checkingRow];
                    if (dest.empty) {
                        dest.empty = NO;
                        dest.isDoubleMove = NO;
                        dest.firstTileOrigin = [NSIndexPath indexPathForRow:row inSection:column];
                        dest.secondTileOrigin = nil;
                    }
                    else {
                        // The tile here was moved by an earlier iteration. We need to perform a double merge.
                        dest.isDoubleMove = YES;
                        dest.secondTileOrigin = [NSIndexPath indexPathForRow:row inSection:column];
                    }
                    dest.finalValue = tile.value * 2;
                    // Update board state
                    tile.empty = YES;
                    checkingTile.empty = NO;
                    checkingTile.value = tile.value * 2;
                    break;
                }
            }
            if (!mergeNeeded && newRow != row) {
                NSAssert(((F3HDestination *)destinationArray[newRow]).empty, @"Logic error: non-empty destination when moving tile without merge");
                F3HDestination *dest = destinationArray[newRow];
                dest.empty = NO;
                dest.isDoubleMove = NO;
                dest.firstTileOrigin = [NSIndexPath indexPathForRow:row inSection:column];
                dest.secondTileOrigin = nil;
                dest.finalValue = tile.value;
                // Update board state
                tile.empty = YES;
                F3HTile *newTile = [self tileForIndexPath:[NSIndexPath indexPathForRow:newRow inSection:column]];
                newTile.empty = NO;
                newTile.value = tile.value;
            }
        }
        
        // Execute all moves
        for (NSInteger i=self.dimension-1; i>=0; i--) {
            F3HDestination *destination = destinationArray[i];
            if (!destination.empty) {
                if (destination.isDoubleMove) {
                    [self.delegate moveTileOne:destination.firstTileOrigin
                                       tileTwo:destination.secondTileOrigin
                                   toIndexPath:[NSIndexPath indexPathForRow:i inSection:column]
                                      newValue:destination.finalValue];
                }
                else {
                    [self.delegate moveTileFromIndexPath:destination.firstTileOrigin
                                             toIndexPath:[NSIndexPath indexPathForRow:i inSection:column]
                                                newValue:destination.finalValue];
                }
            }
            // Reset the array
            [destinationArray[i] reset];
        }
    }
}

- (void)performDownMove {
    NSMutableArray *destinationArray = [NSMutableArray array];
    for (NSInteger i=0; i<self.dimension; i++) {
        [destinationArray addObject:[F3HDestination emptyDestination]];
    }
    
    // Examine each column at a time
    for (NSInteger column=0; column<self.dimension; column++) {
        // Examine each row in a given column
        for (NSInteger row=(self.dimension-2); row >= 0; row--) {
            // Get the current tile
            NSIndexPath *originalPath = [NSIndexPath indexPathForRow:row inSection:column];
            F3HTile *tile = [self tileForIndexPath:originalPath];
            if (tile.empty) continue;
            
            // Move the tile down as far as possible
            NSInteger newRow = row; // The new row to move the tile to, if any
            BOOL mergeNeeded = NO;
            for (NSInteger checkingRow = row+1; checkingRow < self.dimension; checkingRow++) {
                F3HTile *checkingTile = [self tileForIndexPath:[NSIndexPath indexPathForRow:checkingRow inSection:column]];
                if (checkingTile.empty) {
                    // The current space is empty. It may be a candidate for moving the tile
                    newRow = checkingRow;
                }
                else if (checkingTile.value == tile.value) {
                    mergeNeeded = YES;
                    // The current space is occupied, but has the same value. We must merge into this tile
                    newRow = checkingRow;
                    // Make a new destination object
                    F3HDestination *dest = destinationArray[checkingRow];
                    if (dest.empty) {
                        dest.empty = NO;
                        dest.isDoubleMove = NO;
                        dest.firstTileOrigin = [NSIndexPath indexPathForRow:row inSection:column];
                        dest.secondTileOrigin = nil;
                    }
                    else {
                        // The tile here was moved by an earlier iteration. We need to perform a double merge.
                        dest.isDoubleMove = YES;
                        dest.secondTileOrigin = [NSIndexPath indexPathForRow:row inSection:column];
                    }
                    dest.finalValue = tile.value * 2;
                    // Update board state
                    tile.empty = YES;
                    checkingTile.empty = NO;
                    checkingTile.value = tile.value * 2;
                    break;
                }
            }
            if (!mergeNeeded && newRow != row) {
                NSAssert(((F3HDestination *)destinationArray[newRow]).empty, @"Logic error: non-empty destination when moving tile without merge");
                F3HDestination *dest = destinationArray[newRow];
                dest.empty = NO;
                dest.isDoubleMove = NO;
                dest.firstTileOrigin = [NSIndexPath indexPathForRow:row inSection:column];
                dest.secondTileOrigin = nil;
                dest.finalValue = tile.value;
                // Update board state
                tile.empty = YES;
                F3HTile *newTile = [self tileForIndexPath:[NSIndexPath indexPathForRow:newRow inSection:column]];
                newTile.empty = NO;
                newTile.value = tile.value;
            }
        }
        
        // Execute all moves
        for (NSInteger i=0; i<self.dimension; i++) {
            F3HDestination *destination = destinationArray[i];
            if (!destination.empty) {
                if (destination.isDoubleMove) {
                    [self.delegate moveTileOne:destination.firstTileOrigin
                                       tileTwo:destination.secondTileOrigin
                                   toIndexPath:[NSIndexPath indexPathForRow:i inSection:column]
                                      newValue:destination.finalValue];
                }
                else {
                    [self.delegate moveTileFromIndexPath:destination.firstTileOrigin
                                             toIndexPath:[NSIndexPath indexPathForRow:i inSection:column]
                                                newValue:destination.finalValue];
                }
            }
            // Reset the array
            [destinationArray[i] reset];
        }
    }
}

- (void)performLeftMove {
    NSMutableArray *destinationArray = [NSMutableArray array];
    for (NSInteger i=0; i<self.dimension; i++) {
        [destinationArray addObject:[F3HDestination emptyDestination]];
    }
    
    // Examine each row at a time
    for (NSInteger row=0; row<self.dimension; row++) {
        // Examine each column in a given row
        for (NSInteger column=1; column<self.dimension; column++) {
            // Get the current tile
            NSIndexPath *originalPath = [NSIndexPath indexPathForRow:row inSection:column];
            F3HTile *tile = [self tileForIndexPath:originalPath];
            if (tile.empty) continue;
            
            // Move the tile to the left as much as possible
            NSInteger newColumn = column; // The new row to move the tile to, if any
            BOOL mergeNeeded = NO;
            for (NSInteger checkingColumn = column-1; checkingColumn >= 0; checkingColumn--) {
                F3HTile *checkingTile = [self tileForIndexPath:[NSIndexPath indexPathForRow:row inSection:checkingColumn]];
                if (checkingTile.empty) {
                    // The current space is empty. It may be a candidate for moving the tile
                    newColumn = checkingColumn;
                }
                else if (checkingTile.value == tile.value) {
                    mergeNeeded = YES;
                    // The current space is occupied, but has the same value. We must merge into this tile
                    newColumn = checkingColumn;
                    // Make a new destination object
                    F3HDestination *dest = destinationArray[checkingColumn];
                    if (dest.empty) {
                        dest.empty = NO;
                        dest.isDoubleMove = NO;
                        dest.firstTileOrigin = [NSIndexPath indexPathForRow:row inSection:column];
                        dest.secondTileOrigin = nil;
                    }
                    else {
                        // The tile here was moved by an earlier iteration. We need to perform a double merge.
                        dest.isDoubleMove = YES;
                        dest.secondTileOrigin = [NSIndexPath indexPathForRow:row inSection:column];
                    }
                    dest.finalValue = tile.value * 2;
                    // Update board state
                    tile.empty = YES;
                    checkingTile.empty = NO;
                    checkingTile.value = tile.value * 2;
                    break;
                }
            }
            if (!mergeNeeded && newColumn != column) {
                NSAssert(((F3HDestination *)destinationArray[newColumn]).empty, @"Logic error: non-empty destination when moving tile without merge");
                F3HDestination *dest = destinationArray[newColumn];
                dest.empty = NO;
                dest.isDoubleMove = NO;
                dest.firstTileOrigin = [NSIndexPath indexPathForRow:row inSection:column];
                dest.secondTileOrigin = nil;
                dest.finalValue = tile.value;
                // Update board state
                tile.empty = YES;
                F3HTile *newTile = [self tileForIndexPath:[NSIndexPath indexPathForRow:row inSection:newColumn]];
                newTile.empty = NO;
                newTile.value = tile.value;
            }
        }
        
        // Execute all moves
        for (NSInteger i=self.dimension-1; i>=0; i--) {
            F3HDestination *destination = destinationArray[i];
            if (!destination.empty) {
                if (destination.isDoubleMove) {
                    [self.delegate moveTileOne:destination.firstTileOrigin
                                       tileTwo:destination.secondTileOrigin
                                   toIndexPath:[NSIndexPath indexPathForRow:row inSection:i]
                                      newValue:destination.finalValue];
                }
                else {
                    [self.delegate moveTileFromIndexPath:destination.firstTileOrigin
                                             toIndexPath:[NSIndexPath indexPathForRow:row inSection:i]
                                                newValue:destination.finalValue];
                }
            }
            // Reset the array
            [destinationArray[i] reset];
        }
    }
}

- (void)performRightMove {
    NSMutableArray *destinationArray = [NSMutableArray array];
    for (NSInteger i=0; i<self.dimension; i++) {
        [destinationArray addObject:[F3HDestination emptyDestination]];
    }
    
    // Examine each row at a time
    for (NSInteger row=0; row<self.dimension; row++) {
        // Examine each column in a given row
        for (NSInteger column=(self.dimension - 2); column >= 0; column--) {
            // Get the current tile
            NSIndexPath *originalPath = [NSIndexPath indexPathForRow:row inSection:column];
            F3HTile *tile = [self tileForIndexPath:originalPath];
            if (tile.empty) continue;
            
            // Move the tile to the left as much as possible
            NSInteger newColumn = column; // The new row to move the tile to, if any
            BOOL mergeNeeded = NO;
            for (NSInteger checkingColumn = column+1; checkingColumn < self.dimension; checkingColumn++) {
                F3HTile *checkingTile = [self tileForIndexPath:[NSIndexPath indexPathForRow:row inSection:checkingColumn]];
                if (checkingTile.empty) {
                    // The current space is empty. It may be a candidate for moving the tile
                    newColumn = checkingColumn;
                }
                else if (checkingTile.value == tile.value) {
                    mergeNeeded = YES;
                    // The current space is occupied, but has the same value. We must merge into this tile
                    newColumn = checkingColumn;
                    // Make a new destination object
                    F3HDestination *dest = destinationArray[checkingColumn];
                    if (dest.empty) {
                        dest.empty = NO;
                        dest.isDoubleMove = NO;
                        dest.firstTileOrigin = [NSIndexPath indexPathForRow:row inSection:column];
                        dest.secondTileOrigin = nil;
                    }
                    else {
                        // The tile here was moved by an earlier iteration. We need to perform a double merge.
                        dest.isDoubleMove = YES;
                        dest.secondTileOrigin = [NSIndexPath indexPathForRow:row inSection:column];
                    }
                    dest.finalValue = tile.value * 2;
                    // Update board state
                    tile.empty = YES;
                    checkingTile.empty = NO;
                    checkingTile.value = tile.value * 2;
                    break;
                }
            }
            if (!mergeNeeded && newColumn != column) {
                NSAssert(((F3HDestination *)destinationArray[newColumn]).empty, @"Logic error: non-empty destination when moving tile without merge");
                F3HDestination *dest = destinationArray[newColumn];
                dest.empty = NO;
                dest.isDoubleMove = NO;
                dest.firstTileOrigin = [NSIndexPath indexPathForRow:row inSection:column];
                dest.secondTileOrigin = nil;
                dest.finalValue = tile.value;
                // Update board state
                tile.empty = YES;
                F3HTile *newTile = [self tileForIndexPath:[NSIndexPath indexPathForRow:row inSection:newColumn]];
                newTile.empty = NO;
                newTile.value = tile.value;
            }
        }
        
        // Execute all moves
        for (NSInteger i=0; i<self.dimension; i++) {
            F3HDestination *destination = destinationArray[i];
            if (!destination.empty) {
                if (destination.isDoubleMove) {
                    [self.delegate moveTileOne:destination.firstTileOrigin
                                       tileTwo:destination.secondTileOrigin
                                   toIndexPath:[NSIndexPath indexPathForRow:row inSection:i]
                                      newValue:destination.finalValue];
                }
                else {
                    [self.delegate moveTileFromIndexPath:destination.firstTileOrigin
                                             toIndexPath:[NSIndexPath indexPathForRow:row inSection:i]
                                                newValue:destination.finalValue];
                }
            }
            // Reset the array
            [destinationArray[i] reset];
        }
    }
}

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

@end

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

@implementation F3HDestination

+ (instancetype)emptyDestination {
    F3HDestination *destination = [[self class] new];
    [destination reset];
    return destination;
}

- (void)reset {
    self.empty = YES;
    self.firstTileOrigin = nil;
    self.secondTileOrigin = nil;
    self.isDoubleMove = NO;
    self.finalValue = 0;
}

- (NSString *)description {
    if (self.empty) {
        return @"Destination (empty)";
    }
    else if (self.isDoubleMove) {
        return [NSString stringWithFormat:@"Double move destination (source 1: row %d, column %d; source 2: row %d, column %d)",
                self.firstTileOrigin.row, self.firstTileOrigin.section,
                self.secondTileOrigin.row, self.secondTileOrigin.section];
    }
    else {
        return [NSString stringWithFormat:@"Single move destination (source: row %d, column %d)",
                self.firstTileOrigin.row, self.firstTileOrigin.section];
    }
}

@end