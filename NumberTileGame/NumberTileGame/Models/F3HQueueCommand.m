//
//  F3HQueueCommand.m
//  NumberTileGame
//
//  Created by Austin Zheng on 3/24/14.
//
//

#import "F3HQueueCommand.h"

@implementation F3HQueueCommand

+ (instancetype)commandWithDirection:(F3HMoveDirection)direction
                     completionBlock:(void(^)(BOOL))completion {
    F3HQueueCommand *command = [[self class] new];
    command.direction = direction;
    command.completion = completion;
    return command;
}

@end
