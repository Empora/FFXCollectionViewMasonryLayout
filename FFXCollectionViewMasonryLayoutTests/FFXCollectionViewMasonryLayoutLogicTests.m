//
//  FFXCollectionViewMasonryLayoutLogicTests.m
//  FFXCollectionViewMasonryLayout
//
//  Created by Sebastian Boldt on 10.02.15.
//  Copyright (c) 2015 Empora. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import "FFXCollectionViewMasonryLayoutLogic.h"
#import "FFXCollectionViewMasonryLayout.h"
#import "FFXCollectionViewMasonryLayoutLogic_Internal.h"

#define COLLECTIONVIEW_WIDTH 375
#define PADDING_LEFT 8
#define PADDING_RIGHT 9
#define PADDING_TOP 10
#define PADDING_BOTTOM 11
@interface FFXCollectionViewMasonryLayoutLogicTests : XCTestCase
@property(nonatomic,strong) FFXCollectionViewMasonryLayoutLogic * logicToTest;
@property (nonatomic,strong) NSMutableArray * testModel;

@end

@implementation FFXCollectionViewMasonryLayoutLogicTests

- (void)setUp {
    [super setUp];
    [self setupTestModelWithNumberOfItems:1000];
    self.logicToTest = [[FFXCollectionViewMasonryLayoutLogic alloc]init];
    self.logicToTest.numberOfItems = 1000;
    self.logicToTest.interItemSpacing = 5;
    self.logicToTest.padding = UIEdgeInsetsMake(PADDING_TOP,PADDING_LEFT,PADDING_BOTTOM,PADDING_RIGHT); // top,left, bottom, right
    self.logicToTest.numberOfColums = 2;
    self.logicToTest.lastYValueForColumns = [self prepareLastYValueArrayForNumberOfColumns:self.logicToTest.numberOfColums withValue:@(0)];
    self.logicToTest.collectionViewFrame = CGRectMake(0, 0, 367,0);
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

-(void)testThatLogicExists {
    XCTAssertNotNil(self.logicToTest,@"should be able to create a logic Instance");
}

- (void) testComputeFunctionPerformance {
    // Testing with one Million items
    [self setupTestModelWithNumberOfItems:10000];
    self.logicToTest.numberOfItems = 10000;
    __block NSDictionary * layoutAttributes = nil;
    [self measureBlock:^{
        layoutAttributes= [self.logicToTest computeLayoutWithmeasureItemBlock:^CGSize(NSInteger itemIndex,CGRect frame){
            CGSize itemSize = [self getSizeForIndexPath:[NSIndexPath indexPathForItem:itemIndex inSection:0]];
            return itemSize;
        }];
    }];
}

-(void)testThatNumberOfLayoutAttributesIsCorrect {
    NSDictionary * layoutAttributes = [self.logicToTest computeLayoutWithmeasureItemBlock:^CGSize(NSInteger itemIndex,CGRect frame){
        CGSize itemSize = [self getSizeForIndexPath:[NSIndexPath indexPathForItem:itemIndex inSection:0]];
        return itemSize;
    }];
    XCTAssertTrue(self.logicToTest.numberOfItems == layoutAttributes.count, @"number of layout attributes should be equal to all number of items passed to layoutLogic");
}

#pragma mark - Padding Tests
-(void)testThatLeftPaddingHasCorrectValue {
    XCTAssertTrue(self.logicToTest.padding.left == PADDING_LEFT,@"left padding should be set to correct value");
}
-(void)testThatRightPaddingHasCorrectValue {
    XCTAssertTrue(self.logicToTest.padding.right == PADDING_RIGHT,@"right padding should be set to correct value");
}
-(void)testThatBottomPaddingHasCorrectValue {
    XCTAssertTrue(self.logicToTest.padding.bottom == PADDING_BOTTOM,@"bottom padding should be set to correct value");
}
-(void)testThatTopPaddingHasCorrectValue {
    XCTAssertTrue(self.logicToTest.padding.top == PADDING_TOP,@"top padding should be set");
}

-(void)testThatLeftPaddingWorksCorrectly {
    NSDictionary * layoutAttributes = [self.logicToTest computeLayoutWithmeasureItemBlock:^CGSize(NSInteger itemIndex,CGRect frame){
        CGSize itemSize = [self getSizeForIndexPath:[NSIndexPath indexPathForItem:itemIndex inSection:0]];
        return itemSize;
    }];
    
    for (int i = 0 ; i<self.logicToTest.numberOfItems; i++) {
        UICollectionViewLayoutAttributes * attributes = [layoutAttributes objectForKey:[NSIndexPath indexPathForItem:i inSection:0]];
        XCTAssertTrue(attributes.frame.origin.x >= self.logicToTest.padding.left,@"left padding should be correctly applied to all layout Attributes");
    }
}

-(void)testThatRightPaddingWorksCorrectly {
    NSDictionary * layoutAttributes = [self.logicToTest computeLayoutWithmeasureItemBlock:^CGSize(NSInteger itemIndex,CGRect frame){
        CGSize itemSize = [self getSizeForIndexPath:[NSIndexPath indexPathForItem:itemIndex inSection:0]];
        return itemSize;
    }];
    
    for (int i = 0 ; i<self.logicToTest.numberOfItems; i++) {
        UICollectionViewLayoutAttributes * attributes = [layoutAttributes objectForKey:[NSIndexPath indexPathForItem:i inSection:0]];
        CGFloat sizeOfCollectionViewExcludingPadding = (COLLECTIONVIEW_WIDTH - self.logicToTest.padding.right);
        CGFloat lastXPositionOfItem = (attributes.frame.origin.x+attributes.frame.size.width);
        XCTAssertTrue(lastXPositionOfItem <= sizeOfCollectionViewExcludingPadding,@"right padding should be correctly applied to all layout Attributes");
    }
}

-(void)testThatTopPaddingWorksCorrectly {
    NSDictionary * layoutAttributes = [self.logicToTest computeLayoutWithmeasureItemBlock:^CGSize(NSInteger itemIndex,CGRect frame){
        CGSize itemSize = [self getSizeForIndexPath:[NSIndexPath indexPathForItem:itemIndex inSection:0]];
        return itemSize;
    }];
    
    for (int i = 0 ; i<self.logicToTest.numberOfItems; i++) {
        UICollectionViewLayoutAttributes * attributes = [layoutAttributes objectForKey:[NSIndexPath indexPathForItem:i inSection:0]];
        XCTAssertTrue(attributes.frame.origin.y >= PADDING_TOP,@"top padding should be correctly applied to all layout Attributes");
    }
}

-(void)testThatBottomPaddingWorksCorrectly {
    NSDictionary * layoutAttributes = [self.logicToTest computeLayoutWithmeasureItemBlock:^CGSize(NSInteger itemIndex,CGRect frame){
        CGSize itemSize = [self getSizeForIndexPath:[NSIndexPath indexPathForItem:itemIndex inSection:0]];
        return itemSize;
    }];
    
    for (int i = 0 ; i<self.logicToTest.numberOfItems; i++) {
        UICollectionViewLayoutAttributes * attributes = [layoutAttributes objectForKey:[NSIndexPath indexPathForItem:i inSection:0]];
        XCTAssertTrue(attributes.frame.origin.y+attributes.frame.size.height >= PADDING_BOTTOM,@"bottom padding should be correctly applied to all layout Attributes");
    }
}

#pragma mark - Interitemspacing Tests
-(void)testThatIterItemSpacingHasCorrectValue {
    XCTAssertTrue(self.logicToTest.interItemSpacing == 5,@"Interitemspacing should be set");
}
#pragma mark -- Delegate Mocking Functions

// returning random Size for each item
- (CGSize)getSizeForIndexPath:(NSIndexPath*)indexPath{
    NSString * string = [self.testModel objectAtIndex:indexPath.row];
    if ([string isEqualToString:@"A"]) { // fullspan
        CGSize temp = CGSizeMake(COLLECTIONVIEW_WIDTH, 200 + (arc4random() % 10));
        return temp;
    } else {
        // Random string
        CGSize temp = CGSizeMake(30, 200 + (arc4random() % 100));
        return temp;
    }
}

// Creates some Testdata A  equals fullspan, b equals random sized element
-(void)setupTestModelWithNumberOfItems:(NSUInteger)numberOfItems {
    self.testModel = [[NSMutableArray alloc]init];
    //Create some TestData
    for (int i = 0 ; i <numberOfItems; i++) {
        int r = arc4random() % 5; // 5 different Kinds of Elements
        if (r == 1) {
            [self.testModel addObject:@"A"]; // A is Fullspan
        } else [self.testModel addObject:@"B"]; // B is Random element
    }
}

-(NSMutableArray*)prepareLastYValueArrayForNumberOfColumns:(NSInteger)numberOfColums withValue:(NSNumber*)value {
    NSMutableArray *array = [[NSMutableArray alloc]init];
    for (int i = 0; i< numberOfColums; i++) {
        [array addObject:value];
    }
    return array;
}


@end
