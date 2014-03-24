//
//  F3HGameModel.h
//  NumberTileGame
//
//  Created by Austin Zheng on 3/23/14.
//
//

#import <Foundation/Foundation.h>

typedef enum {
    F3HMoveDirectionUp = 0,
    F3HMoveDirectionDown,
    F3HMoveDirectionLeft,
    F3HMoveDirectionRight
} F3HMoveDirection;

@protocol F3HGameModelProtocol

- (void)playerLost;
- (void)playerWonWithTile:(NSIndexPath *)tilePath;
- (void)moveTileFromIndexPath:(NSIndexPath *)fromPath
                  toIndexPath:(NSIndexPath *)toPath
                     newValue:(NSUInteger)value;
- (void)moveTileOne:(NSIndexPath *)startA
            tileTwo:(NSIndexPath *)startB
        toIndexPath:(NSIndexPath *)end
           newValue:(NSUInteger)value;
- (void)insertTileAtIndexPath:(NSIndexPath *)path
                        value:(NSUInteger)value;

@end

@interface F3HGameModel : NSObject

+ (instancetype)gameModelWithDimension:(NSUInteger)dimension
                              winValue:(NSUInteger)value
                              delegate:(id<F3HGameModelProtocol>)delegate;

- (void)insertAtRandomLocationTileWithValue:(NSUInteger)value;

- (void)insertTileWithValue:(NSUInteger)value
                atIndexPath:(NSIndexPath *)path;

- (BOOL)performMoveInDirection:(F3HMoveDirection)direction;

- (BOOL)userHasLost;
- (BOOL)userHasWon;

#pragma mark - Test

- (NSArray *)mergeGroup:(NSArray *)group;

@end

@interface F3HMoveOrder : NSObject
@property (nonatomic) NSInteger source1;
@property (nonatomic) NSInteger source2;
@property (nonatomic) NSInteger destination;
@property (nonatomic) BOOL doubleMove;
@property (nonatomic) NSInteger value;
@end
