//
//  FFXCollectionViewMasonryLayoutTests.m
//  FFXCollectionViewMasonryLayoutTests
//
//  Created by Sebastian Boldt on 06.02.15.
//  Copyright (c) 2015 Empora. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import "FFXCollectionViewMasonryLayout.h"
@interface FFXCollectionViewMasonryLayoutTests : XCTestCase

@end

@implementation FFXCollectionViewMasonryLayoutTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testPerformanceOfPrepareLayout {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}

- (void) testUICollectionViewDataSource
{
    // Cells should not be nil
    //XCTAssertNotNil(cell, @"Cell should not be nil");
}

@end
