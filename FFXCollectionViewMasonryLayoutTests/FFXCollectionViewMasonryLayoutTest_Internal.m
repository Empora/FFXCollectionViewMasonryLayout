//
//  FFXCollectionViewMasonryLayoutTest_Internal.m
//  FFXCollectionViewMasonryLayout
//
//  Created by Sebastian Boldt on 17.02.15.
//  Copyright (c) 2015 Empora. All rights reserved.
//
#import "FFXCollectionViewMasonryLayoutLogic.h" 
#import "FFXCollectionViewMasonryLayoutLogic_Internal.h"
#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#define COLLECTIONVIEW_WIDTH 375
#define PADDING_LEFT 8
#define PADDING_RIGHT 9
#define PADDING_TOP 10
#define PADDING_BOTTOM 11

@interface FFXCollectionViewMasonryLayoutTest_Internal : XCTestCase
@property(nonatomic,strong) FFXCollectionViewMasonryLayoutLogic * logicToTest;
@property (nonatomic,strong) NSMutableArray * testModel;
@end

@implementation FFXCollectionViewMasonryLayoutTest_Internal

- (void)setUp {
    [super setUp];
    [self setupTestModelWithNumberOfItems:1000];
    self.logicToTest = [[FFXCollectionViewMasonryLayoutLogic alloc]init];
    self.logicToTest.numberOfItems = 1000;
    self.logicToTest.interItemSpacing = 5;
    self.logicToTest.padding = UIEdgeInsetsMake(PADDING_TOP,PADDING_LEFT,PADDING_BOTTOM,PADDING_RIGHT); // top,left, bottom, right
    self.logicToTest.numberOfColums = 2;
    self.logicToTest.lastYValueForColumns = [self prepareLastYValueArrayForNumberOfColumns:self.logicToTest.numberOfColums withValue:@(0)];
    self.logicToTest.collectionViewFrame = CGRectMake(0, 0, 367,0);}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

#pragma mark - private method testing

-(void)testThatMasterStackGetCorrectlyConfigured {
    NSMutableArray * masterStack = [self.logicToTest prepareMasterStackForSection:100];
    XCTAssertTrue(masterStack.count == 100,@"masterstack should have same size as number of items");
}

-(void)testThatMasterStackIsEmptyAfterComputing {
    [self.logicToTest computeLayoutWithmeasureItemBlock:^CGSize(NSInteger itemIndex,CGRect frame){
        CGSize itemSize = [self getSizeForIndexPath:[NSIndexPath indexPathForItem:itemIndex inSection:0]];
        return itemSize;
    }];
    
    XCTAssert(self.logicToTest.masterStack.count == 0,@"masterStack should be empty after computing all layout attributes");
}

-(void)testThatFullspanStackIsEmptyAfterComputing {
    [self.logicToTest computeLayoutWithmeasureItemBlock:^CGSize(NSInteger itemIndex,CGRect frame){
        CGSize itemSize = [self getSizeForIndexPath:[NSIndexPath indexPathForItem:itemIndex inSection:0]];
        return itemSize;
    }];
    
    XCTAssert(self.logicToTest.masterStack.count == 0,@"masterStack should be empty after computing all layout attributes");
}

-(void)testThatItemWidthIsCorrectlyCalculated {
    [self.logicToTest computeLayoutWithmeasureItemBlock:^CGSize(NSInteger itemIndex,CGRect frame){
        CGSize itemSize = [self getSizeForIndexPath:[NSIndexPath indexPathForItem:itemIndex inSection:0]];
        return itemSize;
    }];
    CGFloat widthOfItem = [self.logicToTest getWidthOfItem];
    CGFloat fullWidth = self.logicToTest.collectionViewFrame.size.width;
    CGFloat availableSpaceExcludingPadding = fullWidth - (self.logicToTest.padding.right + self.logicToTest.padding.left) - ((self.logicToTest.numberOfColums-1)*self.logicToTest.interItemSpacing);
    XCTAssert(widthOfItem == (availableSpaceExcludingPadding / self.logicToTest.numberOfColums), @"width of item should be correctly sized");
}

-(void)testThatFullSpanElementIsDetectedCorrectly {
    BOOL fullspan = [self.logicToTest checkIfElementIsFullSpan:CGSizeMake(([self.logicToTest getWidthOfItem]+1),200)];
    XCTAssert(fullspan,@"item should be fullspan");
}

-(void)testThatNoFullSpanElementIsDetectedCorrectly {
    BOOL fullspan = [self.logicToTest checkIfElementIsFullSpan:CGSizeMake(([self.logicToTest getWidthOfItem]-1),200)];
    XCTAssert(fullspan,@"item should not be fullspan");
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
