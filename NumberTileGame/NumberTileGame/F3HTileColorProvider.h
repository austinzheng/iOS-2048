//
//  F3HTileColorProvider.h
//  NumberTileGame
//
//  Created by Austin Zheng on 3/22/14.
//
//

#import <Foundation/Foundation.h>

@protocol F3HTileColorProviderProtocol <NSObject>

- (UIColor *)tileColorForValue:(NSUInteger)value;
- (UIColor *)numberColorForValue:(NSUInteger)value;

@end

@interface F3HTileColorProvider : NSObject <F3HTileColorProviderProtocol>

@end
