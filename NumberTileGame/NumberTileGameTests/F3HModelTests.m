//
//  F3HModelTests.m
//  NumberTileGame
//
//  Created by Austin Zheng on 3/24/14.
//
//

#import <XCTest/XCTest.h>

#import "F3HGameModel.h"
#import "F3HMoveOrder.h"
#import "F3HTileModel.h"
#import "F3HMergeTile.h"

@interface F3HGameModel ()
- (NSArray *)mergeGroup:(NSArray *)group;
@end

@interface F3HModelTests : XCTestCase
@end

@implementation F3HModelTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

// Test basic scenario: no moves or merges
- (void)testModelMerge1 {
    F3HGameModel *model = [F3HGameModel gameModelWithDimension:5 winValue:2048 delegate:nil];
    XCTAssertNotNil(model, @"model should not be nil, when created with test parameters");
    
    F3HTileModel *t1 = [F3HTileModel emptyTile];
    t1.value = 1;
    t1.empty = NO;
    F3HTileModel *t2 = [F3HTileModel emptyTile];
    t2.value = 2;
    t2.empty = NO;
    F3HTileModel *t3 = [F3HTileModel emptyTile];
    t3.value = 4;
    t3.empty = NO;
    F3HTileModel *t4 = [F3HTileModel emptyTile];
    t4.value = 8;
    t4.empty = NO;
    F3HTileModel *t5 = [F3HTileModel emptyTile];
    t5.value = 1;
    t5.empty = NO;
    
    NSArray *tiles = @[t1, t2, t3, t4, t5];
    NSArray *moveOrders = [model mergeGroup:tiles];
    XCTAssert([moveOrders count] == 0, @"No move orders should have happened");
}

// Test basic scenario: some moves
- (void)testModelMerge2 {
    F3HGameModel *model = [F3HGameModel gameModelWithDimension:5 winValue:2048 delegate:nil];
    XCTAssertNotNil(model, @"model should not be nil, when created with test parameters");
    
    F3HTileModel *t1 = [F3HTileModel emptyTile];
    t1.value = 1;
    t1.empty = NO;
    F3HTileModel *t2 = [F3HTileModel emptyTile];
    // T2 is empty
    F3HTileModel *t3 = [F3HTileModel emptyTile];
    t3.value = 4;
    t3.empty = NO;
    F3HTileModel *t4 = [F3HTileModel emptyTile];
    // T4 is empty
    F3HTileModel *t5 = [F3HTileModel emptyTile];
    t5.value = 1;
    t5.empty = NO;
    
    NSArray *tiles = @[t1, t2, t3, t4, t5];
    NSArray *moveOrders = [model mergeGroup:tiles];
    XCTAssert([moveOrders count] == 2, @"Two move orders should have happened (got %d)", [moveOrders count]);
    // Check the move orders
    F3HMoveOrder *order = moveOrders[0];
    XCTAssertFalse(order.doubleMove, @"Should not be double move");
    XCTAssertTrue(order.source1 == 2, @"First move order should have source 2 (to destination 1)");
    XCTAssertTrue(order.destination == 1, @"First move order should have destination 1 (from source 2)");
    
    order = moveOrders[1];
    XCTAssertFalse(order.doubleMove, @"Should not be double move");
    XCTAssertTrue(order.source1 == 4, @"Second move order should have source 4 (to destination 2)");
    XCTAssertTrue(order.destination == 2, @"Second move order should have destination 2 (from source 4)");
}

// Test basic scenario: no moves, one merge at end
- (void)testModelMerge3 {
    F3HGameModel *model = [F3HGameModel gameModelWithDimension:5 winValue:2048 delegate:nil];
    XCTAssertNotNil(model, @"model should not be nil, when created with test parameters");
    
    F3HTileModel *t1 = [F3HTileModel emptyTile];
    t1.value = 1;
    t1.empty = NO;
    F3HTileModel *t2 = [F3HTileModel emptyTile];
    t2.value = 2;
    t2.empty = NO;
    F3HTileModel *t3 = [F3HTileModel emptyTile];
    t3.value = 4;
    t3.empty = NO;
    F3HTileModel *t4 = [F3HTileModel emptyTile];
    t4.value = 1;
    t4.empty = NO;
    F3HTileModel *t5 = [F3HTileModel emptyTile];
    t5.value = 1;
    t5.empty = NO;
    
    NSArray *tiles = @[t1, t2, t3, t4, t5];
    NSArray *moveOrders = [model mergeGroup:tiles];
    XCTAssert([moveOrders count] == 1, @"One move order should have happened (got %d)", [moveOrders count]);
    // Check the move orders
    F3HMoveOrder *order = moveOrders[0];
    XCTAssertFalse(order.doubleMove, @"Should not be double move");
    XCTAssertTrue(order.source1 == 4, @"Move order should have source 4");
    XCTAssertTrue(order.destination == 3, @"Move order should have destination 3");
    XCTAssertTrue(order.value == 2, @"Move order should have new value of 2 (received value was %d)", order.value);
}

// Test advanced scenario: one move, one merge
- (void)testModelMerge4 {
    F3HGameModel *model = [F3HGameModel gameModelWithDimension:5 winValue:2048 delegate:nil];
    XCTAssertNotNil(model, @"model should not be nil, when created with test parameters");
    
    F3HTileModel *t1 = [F3HTileModel emptyTile];
    t1.value = 2;
    t1.empty = NO;
    F3HTileModel *t2 = [F3HTileModel emptyTile];
    t2.value = 2;
    t2.empty = NO;
    F3HTileModel *t3 = [F3HTileModel emptyTile];
    t3.value = 16;
    t3.empty = NO;
    F3HTileModel *t4 = [F3HTileModel emptyTile];
    // T4 is empty
    F3HTileModel *t5 = [F3HTileModel emptyTile];
    t5.value = 1;
    t5.empty = NO;
    
    NSArray *tiles = @[t1, t2, t3, t4, t5];
    NSArray *moveOrders = [model mergeGroup:tiles];
    XCTAssert([moveOrders count] == 3, @"Two move orders should have happened (got %d)", [moveOrders count]);
    // Check the move orders
    F3HMoveOrder *order = moveOrders[0];
    XCTAssertFalse(order.doubleMove, @"Should not be double move");
    XCTAssertTrue(order.source1 == 1, @"Move order should have source 1");
    XCTAssertTrue(order.destination == 0, @"Move order should have destination 0");
    XCTAssertTrue(order.value == 4, @"Move order should have new value of 4 (received value was %d)", order.value);
    
    order = moveOrders[1];
    XCTAssertFalse(order.doubleMove, @"Should not be double move");
    XCTAssertTrue(order.source1 == 2, @"Move order should have source 4");
    XCTAssertTrue(order.destination == 1, @"Move order should have destination 2 (was %d)", order.destination);
    XCTAssertTrue(order.value == 16, @"Move order should have new value of 1 (received value was %d)", order.value);
    
    order = moveOrders[2];
    XCTAssertFalse(order.doubleMove, @"Should not be double move");
    XCTAssertTrue(order.source1 == 4, @"Move order should have source 4");
    XCTAssertTrue(order.destination == 2, @"Move order should have destination 2 (was %d)", order.destination);
    XCTAssertTrue(order.value == 1, @"Move order should have new value of 1 (received value was %d)", order.value);
}

// Test advanced scenario: multi-merge of 3 equal values
- (void)testModelMerge5 {
    F3HGameModel *model = [F3HGameModel gameModelWithDimension:5 winValue:2048 delegate:nil];
    XCTAssertNotNil(model, @"model should not be nil, when created with test parameters");
    
    F3HTileModel *t1 = [F3HTileModel emptyTile];
    t1.value = 2;
    t1.empty = NO;
    F3HTileModel *t2 = [F3HTileModel emptyTile];
    t2.value = 2;
    t2.empty = NO;
    F3HTileModel *t3 = [F3HTileModel emptyTile];
    t3.value = 2;
    t3.empty = NO;
    F3HTileModel *t4 = [F3HTileModel emptyTile];
    // T4 is empty
    F3HTileModel *t5 = [F3HTileModel emptyTile];
    // T4 is empty
    
    NSArray *tiles = @[t1, t2, t3, t4, t5];
    NSArray *moveOrders = [model mergeGroup:tiles];
    XCTAssert([moveOrders count] == 2, @"Two move orders should have happened (got %d)", [moveOrders count]);
    // Check the move orders
    F3HMoveOrder *order = moveOrders[0];
    XCTAssertFalse(order.doubleMove, @"Should not be double move");
    XCTAssertTrue(order.source1 == 1, @"Move order should have source 1");
    XCTAssertTrue(order.destination == 0, @"Move order should have destination 0");
    XCTAssertTrue(order.value == 4, @"Move order should have new value of 4 (received value was %d)", order.value);
    
    order = moveOrders[1];
    XCTAssertFalse(order.doubleMove, @"Should not be double move");
    XCTAssertTrue(order.source1 == 2, @"Move order should have source 2");
    XCTAssertTrue(order.destination == 1, @"Move order should have destination 1");
    XCTAssertTrue(order.value == 2, @"Move order should have new value of 2 (received value was %d)", order.value);
}

// Test advanced scenario: multiple merges
- (void)testModelMerge6 {
    F3HGameModel *model = [F3HGameModel gameModelWithDimension:5 winValue:2048 delegate:nil];
    XCTAssertNotNil(model, @"model should not be nil, when created with test parameters");
    
    F3HTileModel *t1 = [F3HTileModel emptyTile];
    t1.value = 2;
    t1.empty = NO;
    F3HTileModel *t2 = [F3HTileModel emptyTile];
    t2.value = 2;
    t2.empty = NO;
    F3HTileModel *t3 = [F3HTileModel emptyTile];
    t3.value = 2;
    t3.empty = NO;
    F3HTileModel *t4 = [F3HTileModel emptyTile];
    t4.value = 16;
    t4.empty = NO;
    F3HTileModel *t5 = [F3HTileModel emptyTile];
    t5.value = 16;
    t5.empty = NO;
    
    NSArray *tiles = @[t1, t2, t3, t4, t5];
    NSArray *moveOrders = [model mergeGroup:tiles];
    XCTAssert([moveOrders count] == 3, @"3 move orders should have happened (got %d)", [moveOrders count]);
    // Check the move orders
    F3HMoveOrder *order = moveOrders[0];
    XCTAssertFalse(order.doubleMove, @"Should not be double move");
    XCTAssertTrue(order.source1 == 1, @"Move order should have source 1");
    XCTAssertTrue(order.destination == 0, @"Move order should have destination 0");
    XCTAssertTrue(order.value == 4, @"Move order should have new value of 4 (received value was %d)", order.value);
    
    order = moveOrders[1];
    XCTAssertFalse(order.doubleMove, @"Should not be double move");
    XCTAssertTrue(order.source1 == 2, @"Move order should have source 2");
    XCTAssertTrue(order.destination == 1, @"Move order should have destination 1");
    XCTAssertTrue(order.value == 2, @"Move order should have new value of 2 (received value was %d)", order.value);
    
    order = moveOrders[2];
    XCTAssertTrue(order.doubleMove, @"Should be double move");
    XCTAssertTrue(order.source1 == 3, @"Move order should have source 3");
    XCTAssertTrue(order.source2 == 4, @"Move order should have source 4");
    XCTAssertTrue(order.destination == 2, @"Move order should have destination 2");
    XCTAssertTrue(order.value == 32, @"Move order should have new value of 32 (received value was %d)", order.value);
}

// Test advanced scenario: multiple spaces and merges A
- (void)testModelMerge7 {
    F3HGameModel *model = [F3HGameModel gameModelWithDimension:5 winValue:2048 delegate:nil];
    XCTAssertNotNil(model, @"model should not be nil, when created with test parameters");
    
    F3HTileModel *t1 = [F3HTileModel emptyTile];
    // T1 is empty
    F3HTileModel *t2 = [F3HTileModel emptyTile];
    t2.value = 2;
    t2.empty = NO;
    F3HTileModel *t3 = [F3HTileModel emptyTile];
    t3.value = 2;
    t3.empty = NO;
    F3HTileModel *t4 = [F3HTileModel emptyTile];
    t4.value = 16;
    t4.empty = NO;
    F3HTileModel *t5 = [F3HTileModel emptyTile];
    t5.value = 16;
    t5.empty = NO;

    NSArray *tiles = @[t1, t2, t3, t4, t5];
    NSArray *moveOrders = [model mergeGroup:tiles];
    XCTAssert([moveOrders count] == 2, @"2 move orders should have happened (got %d)", [moveOrders count]);
    // Check the move orders
    F3HMoveOrder *order = moveOrders[0];
    XCTAssertTrue(order.doubleMove, @"Should be double move");
    XCTAssertTrue(order.source1 == 1, @"Move order should have source 1");
    XCTAssertTrue(order.source2 == 2, @"Move order should have source 2");
    XCTAssertTrue(order.destination == 0, @"Move order should have destination 0");
    XCTAssertTrue(order.value == 4, @"Move order should have new value of 4 (received value was %d)", order.value);
    
    order = moveOrders[1];
    XCTAssertTrue(order.doubleMove, @"Should be double move");
    XCTAssertTrue(order.source1 == 3, @"Move order should have source 3");
    XCTAssertTrue(order.source2 == 4, @"Move order should have source 4");
    XCTAssertTrue(order.destination == 1, @"Move order should have destination 1");
    XCTAssertTrue(order.value == 32, @"Move order should have new value of 32 (received value was %d)", order.value);
}

// Test advanced scenario: multiple spaces and merges B
- (void)testModelMerge8 {
    F3HGameModel *model = [F3HGameModel gameModelWithDimension:5 winValue:2048 delegate:nil];
    XCTAssertNotNil(model, @"model should not be nil, when created with test parameters");
    
    F3HTileModel *t1 = [F3HTileModel emptyTile];
    t1.value = 4;
    t1.empty = NO;
    F3HTileModel *t2 = [F3HTileModel emptyTile];
    // T2 is empty
    F3HTileModel *t3 = [F3HTileModel emptyTile];
    t3.value = 4;
    t3.empty = NO;
    F3HTileModel *t4 = [F3HTileModel emptyTile];
    t4.value = 32;
    t4.empty = NO;
    F3HTileModel *t5 = [F3HTileModel emptyTile];
    t5.value = 32;
    t5.empty = NO;
    
    NSArray *tiles = @[t1, t2, t3, t4, t5];
    NSArray *moveOrders = [model mergeGroup:tiles];
    XCTAssert([moveOrders count] == 2, @"2 move orders should have happened (got %d)", [moveOrders count]);
    // Check the move orders
    F3HMoveOrder *order = moveOrders[0];
    XCTAssertFalse(order.doubleMove, @"Should be double move");
    XCTAssertTrue(order.source1 == 2, @"Move order should have source 2");
    XCTAssertTrue(order.destination == 0, @"Move order should have destination 0");
    XCTAssertTrue(order.value == 8, @"Move order should have new value of 8 (received value was %d)", order.value);
    
    order = moveOrders[1];
    XCTAssertTrue(order.doubleMove, @"Should be double move");
    XCTAssertTrue(order.source1 == 3, @"Move order should have source 3");
    XCTAssertTrue(order.source2 == 4, @"Move order should have source 4");
    XCTAssertTrue(order.destination == 1, @"Move order should have destination 1");
    XCTAssertTrue(order.value == 64, @"Move order should have new value of 64 (received value was %d)", order.value);
}

@end
