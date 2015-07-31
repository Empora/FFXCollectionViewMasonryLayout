//
//  FFXCollectionViewMasonryLayoutLogic_Internal.h
//  FFXCollectionViewMasonryLayout
//
//  Created by Sebastian Boldt on 16.02.15.
//  Copyright (c) 2015 Empora. All rights reserved.
//


/***** This class makes private methods public for using them inside unit tests *********/
#import <Foundation/Foundation.h>
#import "FFXCollectionViewMasonryLayoutLogic.h"
@interface FFXCollectionViewMasonryLayoutLogic()
-(void)prepare;
-(NSMutableArray*)prepareMasterStackForSection:(NSInteger)numberOfItems;
-(NSIndexPath*)getNextElement:(BOOL)allowFullspan withMeasurementBlock:(FFXMeasureItemBlock)measurementBlock;
-(void)appendFullSpanElement:(NSIndexPath*)item beforeWasFullSpan:(BOOL)beforeWasFullSpan withMeasurmentBlock:(FFXMeasureItemBlock)measurementBlock;
-(void)appendElement:(NSIndexPath*)item withMeasurementBlock:(FFXMeasureItemBlock)measurementBlock;
-(CGFloat)getWidthOfItem;
-(void)recalculateHeightOfAllElementsAfterFullspan:(NSMutableDictionary*)elementsAfterFullSpan;
-(NSInteger)getLastColumnWithLowestYValue;
-(CGFloat)highestValueOfAllLastColumns;
-(CGFloat)lowestValueOfAllLastColumns;
-(void)setLastYValueForAllColums:(NSNumber*)number;
-(BOOL)checkIfElementIsFullSpan:(CGSize)size;
-(void)prepareLastYValueArray;
-(void)prepareAllElementsAfterFullSpan;

@property (nonatomic, strong) NSMutableArray *fullSpanStack;
@property (nonatomic,strong)  NSMutableArray * masterStack;
@end
