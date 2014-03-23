//
//  F3HTileView.m
//  NumberTileGame
//
//  Created by Austin Zheng on 3/22/14.
//
//

#import "F3HTileView.h"

@interface F3HTileView ()
@property (nonatomic, strong) UILabel *numberLabel;
@end

@implementation F3HTileView

+ (instancetype)tileForPosition:(CGPoint)position
                     sideLength:(CGFloat)side
                          value:(NSUInteger)value {
    F3HTileView *tile = [[[self class] alloc] initWithFrame:CGRectMake(position.x,
                                                                       position.y,
                                                                       side,
                                                                       side)];
    tile.tileValue = value;
    // TODO: fix
    tile.backgroundColor = [UIColor greenColor];
    return tile;
}

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (!self) return nil;
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0,
                                                               0,
                                                               frame.size.width,
                                                               frame.size.height)];
    label.textAlignment = NSTextAlignmentCenter;
    [self addSubview:label];
    self.numberLabel = label;
    // TODO
    return self;
}

- (void)setTileValue:(NSInteger)tileValue {
    _tileValue = tileValue;
    self.numberLabel.text = [@(tileValue) stringValue];
}

@end
