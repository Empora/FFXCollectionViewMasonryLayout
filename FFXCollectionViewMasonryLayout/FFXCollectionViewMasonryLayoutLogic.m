//
//  FFXCollectionViewMasonryLayoutLogic.m
//  IntegrationOfMasonryLayoutToAdvancedCollectionView
//
//  Created by Sebastian Boldt on 09.02.15.
//  Copyright (c) 2015 Empora. All rights reserved.
//

#import "FFXCollectionViewMasonryLayoutLogic.h"
#import "FFXCollectionViewLayoutAttributesMasonry.h"
@interface FFXCollectionViewMasonryLayoutLogic()
@property (nonatomic, strong) NSMutableDictionary   *layoutInfo;            // stores all relevant Information about the CollectionViewCell
@property (nonatomic, strong) NSMutableArray        *fullSpanStack;         // holds all fullspan Elements that didnt fit inside the collectionView
@property (nonatomic,strong)  NSMutableArray * masterStack;
/* temporary Dictionary that stores all Elements after fullSpan like
 row: @(1) --> @[IndexPath1,IndexPath2 ......, IndexPathN]
 row: @(2) --> @[IndexPath1,IndexPath2 ......, IndexPathN]
 row: @(3) --> @[IndexPath1,IndexPath2 ......, IndexPathN] */
@property (nonatomic,strong) NSMutableDictionary * allElementsAfterFullspan;
@property (nonatomic,assign) BOOL firstRow;
@property (nonatomic,assign) CGFloat itemWidth;
@end
@implementation FFXCollectionViewMasonryLayoutLogic

-(void)prepare{
    self.firstRow = YES;
    self.allElementsAfterFullspan = [[NSMutableDictionary alloc]init];
    self.fullSpanStack = [[NSMutableArray alloc]init];
    self.layoutInfo = [NSMutableDictionary dictionary];
    [self prepareAllElementsAfterFullSpan];
    [self prepareMasterStackForSection:self.numberOfItems];
    self.itemWidth = [self getWidthOfItem];
}
-(NSDictionary*)computeLayoutWithmeasureItemBlock:(FFXMeasureItemBlock)measureItemBlock {
    
    [self prepare];
    NSIndexPath * nextItem = nil;
    CGFloat stackedColumns = 0; // Replace by function that calculates how much costs we have to rescale
    BOOL beforeWasFullSpan = NO;
    while ((nextItem = [self getNextElement:!stackedColumns withMeasurementBlock:measureItemBlock])) {
        
        CGSize size = measureItemBlock(nextItem.row,CGRectMake(0, 0, self.itemWidth, 0));
        BOOL isCurrentElementFullspan = [self checkIfElementIsFullSpan:size];
        // If current Element is a fullSpan Element
        if (isCurrentElementFullspan) {
            [self appendFullSpanElement:nextItem beforeWasFullSpan:beforeWasFullSpan withMeasurmentBlock:measureItemBlock];
            self.firstRow = NO;
            stackedColumns = 0; // Column count wieder auf 0 setzen
            beforeWasFullSpan = YES;
        }
        
        else {
            [self appendElement:nextItem withMeasurementBlock:measureItemBlock];
            beforeWasFullSpan = NO;
            stackedColumns ++;
            if(stackedColumns == self.numberOfColums) {
                stackedColumns = 0;
                self.firstRow = NO;
            }
        }
    }
    return self.layoutInfo;
}

//Creates a Master Stack of all IndexPathes
-(void)prepareMasterStackForSection:(NSInteger)numberOfItems {
    self.masterStack = [[NSMutableArray alloc]init];
    for(NSInteger item = 0; item < numberOfItems;item++){
        [self.masterStack insertObject:[NSIndexPath indexPathForItem:item inSection:0] atIndex:self.masterStack.count];
    }
    
}

// Returns next fullspan or single span element
-(NSIndexPath*)getNextElement:(BOOL)allowFullspan withMeasurementBlock:(FFXMeasureItemBlock)measurementBlock {
    NSIndexPath * indexPath = nil;
    
    while (!indexPath) {
        // Get Element from right stack
        BOOL useFullspan = allowFullspan || (self.masterStack.count == 0);
        NSIndexPath * tempIndexPath = nil;
        
        // If masterStack count is Empty and we allowfullspan check if there is an element on a fullspan stack
        // If so, use this element
        if (useFullspan && self.fullSpanStack.count){
            indexPath = [self.fullSpanStack objectAtIndex:0];
            [self.fullSpanStack removeObjectAtIndex:0];
            break;
        }
        
        else if(self.masterStack.count >0){
            
            tempIndexPath = [self.masterStack objectAtIndex:0];
            [self.masterStack removeObjectAtIndex:0];
            
            CGSize size = measurementBlock(tempIndexPath.row,CGRectMake(0, 0, self.itemWidth, 0));
            BOOL isCurrentElementFullspan = [self checkIfElementIsFullSpan:size];
            if (isCurrentElementFullspan) {
                [self.fullSpanStack addObject:tempIndexPath];
            } else {
                indexPath = tempIndexPath;
            }
            
        }
        // If both stacks empty return with nil
        else {
            break;
        }
    }
    if(indexPath == nil){
        CGFloat contentHeight = [self highestValueOfAllLastColumns]+self.padding.bottom;
        [self setLastYValueForAllColums:[NSNumber numberWithFloat:contentHeight]];
    }
    return indexPath;
}

-(void)appendFullSpanElement:(NSIndexPath*)item beforeWasFullSpan:(BOOL)beforeWasFullSpan withMeasurmentBlock:(FFXMeasureItemBlock)measurementBlock {
    if (!beforeWasFullSpan) {
        [self recalculateHeightOfAllElementsAfterFullspan:self.allElementsAfterFullspan];
    }
    FFXCollectionViewLayoutAttributesMasonry * itemAttributes= [FFXCollectionViewLayoutAttributesMasonry layoutAttributesForCellWithIndexPath:item];
    CGSize size = measurementBlock(item.row,CGRectMake(0, 0, self.itemWidth, 0));
    CGFloat x =  self.padding.left;
    CGFloat y = [self highestValueOfAllLastColumns];
    if (self.firstRow) {
        y+= self.padding.top;
    }
    CGFloat width = self.collectionViewFrame.size.width-self.padding.right-self.padding.left;
    itemAttributes.frame = CGRectMake(x, y,width,size.height); // Aspect Ratio stuff has to go here
    itemAttributes.alpha = 0.5;
    itemAttributes.columnIndex = 0;
    y+= size.height;
    y+= self.interItemSpacing;
    self.layoutInfo[item] = itemAttributes;
    [self prepareAllElementsAfterFullSpan];
    [self setLastYValueForAllColums:@(y)];
}

-(void)appendElement:(NSIndexPath*)item withMeasurementBlock:(FFXMeasureItemBlock)measurementBlock {
    FFXCollectionViewLayoutAttributesMasonry * itemAttributes= [FFXCollectionViewLayoutAttributesMasonry layoutAttributesForCellWithIndexPath:item];
    NSInteger columnWidthLowestYValue = [self getLastColumnWitLowestYValue];
    // Calculating x-position
    CGFloat x = 0;
    if (columnWidthLowestYValue == 0) { // If item is first
        x = self.padding.left;
    } else if(columnWidthLowestYValue == self.numberOfColums) { // if element is on the right
        x = (self.interItemSpacing*columnWidthLowestYValue-1) + (columnWidthLowestYValue*self.itemWidth);
    } else { // if is in the middle
        x = self.padding.left +((columnWidthLowestYValue)*self.interItemSpacing)+((columnWidthLowestYValue)*self.itemWidth);
    }
    CGFloat y = [[self.lastYValueForColumns objectAtIndex:columnWidthLowestYValue]floatValue];
    if (self.firstRow) {
        y+= self.padding.top;
    }
    
    // Calulating new height
    CGSize requestedSize = measurementBlock(item.row,CGRectMake(0, 0, self.itemWidth, 0));
    CGFloat width = self.itemWidth;
    CGFloat height = requestedSize.height;
    itemAttributes.frame = CGRectMake(x, y, width, height);
    itemAttributes.columnIndex = columnWidthLowestYValue;
    y+= height;
    y+= self.interItemSpacing;
    [self.lastYValueForColumns replaceObjectAtIndex:columnWidthLowestYValue withObject:@(y)];
    self.layoutInfo[item] = itemAttributes;
    NSMutableArray * allElementsAfterFullSpanTemp= [self.allElementsAfterFullspan objectForKey:@(columnWidthLowestYValue)];
    [allElementsAfterFullSpanTemp addObject:item];
}

-(CGFloat)getWidthOfItem {
    CGFloat fullWidth = self.collectionViewFrame.size.width;
    CGFloat availableSpaceExcludingPadding = fullWidth - (self.padding.left + self.padding.right) - ((self.numberOfColums-1)*self.interItemSpacing);
    return (availableSpaceExcludingPadding / self.numberOfColums);
}

-(void)recalculateHeightOfAllElementsAfterFullspan:(NSMutableDictionary*)elementsAfterFullSpan{
    if ([elementsAfterFullSpan count]>0) { // als Paramater
        // Recalculation Stuff
        NSNumber * avgYValue = [self.lastYValueForColumns valueForKeyPath:@"@avg.floatValue"];
        
        for (id key in self.allElementsAfterFullspan) {
            // If it is bigger rescale all cells down
            NSNumber * lastYValueForRow = [self.lastYValueForColumns objectAtIndex:[key integerValue]];
            
            if ([lastYValueForRow floatValue] > [avgYValue floatValue] ) {
                NSMutableArray * indexPathes = [self.allElementsAfterFullspan objectForKey:key];
                int i = 0;
                CGFloat spaceToReduce = ([lastYValueForRow floatValue] -[avgYValue floatValue])/ [indexPathes count];
                // Get through all IndexPathes
                for (NSIndexPath *path in indexPathes) {
                    // Reduce collectionViewCellSize
                    // Teile den Average Wert durch die Anzahl der Zellen und reduziere die Größe
                    UICollectionViewLayoutAttributes * attributes = self.layoutInfo[path];
                    CGRect newFrame = CGRectMake(attributes.frame.origin.x, attributes.frame.origin.y-(spaceToReduce*(i++)), attributes.frame.size.width, attributes.frame.size.height -spaceToReduce);
                    attributes.frame = newFrame;
                    
                    
                }
            }
            // if it is smaller rescale all cells up
            else {
                // scale up Cell size
                NSMutableArray * indexPathes = [self.allElementsAfterFullspan objectForKey:key];
                CGFloat spaceToScaleUp = -([lastYValueForRow floatValue] -[avgYValue floatValue])/ [indexPathes count];
                int i = 0;
                for (NSIndexPath *path in indexPathes) {
                    // Scale up collectionViewCellSize
                    UICollectionViewLayoutAttributes * attributes = self.layoutInfo[path];
                    CGRect newFrame = CGRectMake(attributes.frame.origin.x, attributes.frame.origin.y+(spaceToScaleUp*i++), attributes.frame.size.width, attributes.frame.size.height +spaceToScaleUp);
                    attributes.frame = newFrame;
                }
            }
        }
        [self setLastYValueForAllColums:avgYValue];
        [self.allElementsAfterFullspan removeAllObjects];
    }
}

-(NSInteger)getLastColumnWitLowestYValue{
    NSNumber * minYValue = [self.lastYValueForColumns valueForKeyPath:@"@min.floatValue"];
    return [self.lastYValueForColumns indexOfObject:minYValue];
}

-(CGFloat)highestValueOfAllLastColumns{
    return [[self.lastYValueForColumns valueForKeyPath:@"@max.intValue"] floatValue];
}

-(CGFloat)lowestValueOfAllLastColumns{
    return [[self.lastYValueForColumns valueForKeyPath:@"@min.intValue"] floatValue];
}
-(void)setLastYValueForAllColums:(NSNumber*)number {
    for (int i = 0; i < self.numberOfColums; i ++) {
        [self.lastYValueForColumns replaceObjectAtIndex:i withObject:number];
    }
}
// This functions determines a fullspan element based on its size
// When should a element become fullspan ?
-(BOOL)checkIfElementIsFullSpan:(CGSize)size {
    // Here we have to define some rules for when a element becomes a full span element
    if (size.width > self.itemWidth) {
        return YES;
    } else {
        return NO;
    }
}

#pragma mark - Helper Functions

// creates an Array with same dimensions as number of columns and initalizes its values with 0 (start point)
-(void)prepareLastYValueArray {
    NSMutableArray *array = [[NSMutableArray alloc]init];
    for (int i = 0; i< self.numberOfColums; i++) {
        [array addObject:@(0)];
    }
    self.lastYValueForColumns =  array;
}

// removes all Elements after fullspan and reinitalizes allElementsAfterFullSpan Member wuth clean Arrays
-(void)prepareAllElementsAfterFullSpan {
    if (self.allElementsAfterFullspan) {
        [self.allElementsAfterFullspan removeAllObjects];
    }
    for (int i = 0; i < self.numberOfColums; i++) {
        [self.allElementsAfterFullspan setObject:[NSMutableArray new] forKey:@(i)];
    }
}

@end
