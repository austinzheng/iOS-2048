//
//  F3HGameboardView.m
//  NumberTileGame
//
//  Created by Austin Zheng on 3/22/14.
//
//

#import "F3HGameboardView.h"

#import <QuartzCore/QuartzCore.h>
#import "F3HTileView.h"
#import "F3HTileColorProvider.h"

#define PER_SQUARE_SLIDE_DURATION 0.08

@interface F3HGameboardView ()

@property (nonatomic, strong) NSMutableDictionary *boardTiles;

@property (nonatomic) NSUInteger dimension;
@property (nonatomic) CGFloat tileSideLength;

@property (nonatomic) CGFloat padding;

@property (nonatomic, strong) F3HTileColorProvider *provider;

@end

@implementation F3HGameboardView

+ (instancetype)gameboardWithDimension:(NSUInteger)dimension
                             cellWidth:(CGFloat)width
                           cellPadding:(CGFloat)padding
                       backgroundColor:(UIColor *)backgroundColor
                       foregroundColor:(UIColor *)foregroundColor {
    
    CGFloat sideLength = padding + dimension*(width + padding);
    F3HGameboardView *view = [[[self class] alloc] initWithFrame:CGRectMake(0,
                                                                            0,
                                                                            sideLength,
                                                                            sideLength)];
    view.dimension = dimension;
    view.padding = padding;
    view.tileSideLength = width;
    [view setupBackgroundWithBackgroundColor:backgroundColor
                             foregroundColor:foregroundColor];
    return view;
}

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (!self) return nil;
    self.layer.cornerRadius = 5;
    return self;
}

- (void)setupBackgroundWithBackgroundColor:(UIColor *)background
                           foregroundColor:(UIColor *)foreground {
    self.backgroundColor = background;
    CGFloat xCursor = self.padding;
    CGFloat yCursor;
    for (NSInteger i=0; i<self.dimension; i++) {
        yCursor = self.padding;
        for (NSInteger j=0; j<self.dimension; j++) {
            // TODO: round corners?
            UIView *bkgndTile = [[UIView alloc] initWithFrame:CGRectMake(xCursor,
                                                                         yCursor,
                                                                         self.tileSideLength,
                                                                         self.tileSideLength)];
            bkgndTile.layer.cornerRadius = 3;
            bkgndTile.backgroundColor = foreground;
            [self addSubview:bkgndTile];
            yCursor += self.padding + self.tileSideLength;
        }
        xCursor += self.padding + self.tileSideLength;
    }
}

// Insert a tile, with the popping animation
- (void)insertTileAtIndexPath:(NSIndexPath *)path
                    withValue:(NSUInteger)value {
    if (!path
        || path.row >= self.dimension
        || path.section >= self.dimension
        || self.boardTiles[path]) {
        // Index path out of bounds, or there already is a tile
        return;
    }
    
    CGFloat x = self.padding + path.section*(self.tileSideLength + self.padding);
    CGFloat y = self.padding + path.row*(self.tileSideLength + self.padding);
    CGPoint position = CGPointMake(x, y);
    F3HTileView *tile = [F3HTileView tileForPosition:position
                                          sideLength:self.tileSideLength
                                               value:value];
    tile.delegate = self.provider;
    [self addSubview:tile];
    self.boardTiles[path] = tile;
    // TODO: Animation:
}

- (void)moveTileOne:(NSIndexPath *)startA
            tileTwo:(NSIndexPath *)startB
        toIndexPath:(NSIndexPath *)end
          withValue:(NSUInteger)value {
    if (!startA || !startB || !self.boardTiles[startA] || !self.boardTiles[startB]
        || end.row >= self.dimension
        || end.section >= self.dimension) {
        NSAssert(NO, @"Invalid two-tile move and merge");
        return;
    }
    F3HTileView *tileA = self.boardTiles[startA];
    F3HTileView *tileB = self.boardTiles[startB];
    
    CGFloat x = self.padding + end.section*(self.tileSideLength + self.padding);
    CGFloat y = self.padding + end.row*(self.tileSideLength + self.padding);
    CGRect finalFrame = tileA.frame;
    finalFrame.origin.x = x;
    finalFrame.origin.y = y;
    
    [UIView animateWithDuration:(PER_SQUARE_SLIDE_DURATION*1)
                     animations:^{
                         tileA.frame = finalFrame;
                         tileB.frame = finalFrame;
                     }
                     completion:^(BOOL finished) {
                         tileA.tileValue = value;
                         [self.boardTiles removeObjectForKey:startA];
                         [self.boardTiles removeObjectForKey:startB];
                         self.boardTiles[end] = tileA;
                         [tileB removeFromSuperview];
                     }];
}

// Move a single tile onto another tile (that stays stationary), merging the two
- (void)moveTileAtIndexPath:(NSIndexPath *)start
                toIndexPath:(NSIndexPath *)end
                  withValue:(NSUInteger)value {
    if (!start || !end || !self.boardTiles[start]
        || end.row >= self.dimension
        || end.section >= self.dimension) {
        NSAssert(NO, @"Invalid one-tile move and merge");
        return;
    }
    F3HTileView *tile = self.boardTiles[start];
    F3HTileView *endTile = self.boardTiles[end];
//    NSInteger distance;
//    if (start.row == end.row) {
//        // Move up and down
//        distance = abs(start.section - end.section);
//    }
//    else if (start.section == end.section) {
//        // Move left and right
//        distance = abs(start.row - end.row);
//    }
//    else {
//        NSAssert(NO, @"Invalid tile movement. Tried to move from %@ to %@", start, end);
//    }
    
    // TODO: finalize animation
    CGFloat x = self.padding + end.section*(self.tileSideLength + self.padding);
    CGFloat y = self.padding + end.row*(self.tileSideLength + self.padding);
    CGRect finalFrame = tile.frame;
    finalFrame.origin.x = x;
    finalFrame.origin.y = y;
    
    [UIView animateWithDuration:(PER_SQUARE_SLIDE_DURATION*1)
                     animations:^{
                         tile.frame = finalFrame;
                     }
                     completion:^(BOOL finished) {
                         tile.tileValue = value;
                         [self.boardTiles removeObjectForKey:start];
                         self.boardTiles[end] = tile;
                         [endTile removeFromSuperview];
                     }];
}

- (F3HTileColorProvider *)provider {
    if (!_provider) {
        _provider = [F3HTileColorProvider new];
    }
    return _provider;
}

- (NSMutableDictionary *)boardTiles {
    if (!_boardTiles) {
        _boardTiles = [NSMutableDictionary dictionary];
    }
    return _boardTiles;
}

@end
