//
//  FFXCollectionViewMasonryLayout.m
//  FFXCollectionViewMasonryLayout
//
//  Created by Sebastian Boldt on 06.02.15.
//  Copyright (c) 2015 Empora. All rights reserved.
//

#import "FFXCollectionViewMasonryLayout.h"

// PseudoCode
/*
 
 NOTES:
 • How to determine which kind of element it is ?
 
 get through all Sections of CollectionView
 get thorugh all Items of Collection View
 
 get column count
 
 ************ Important *************
 if there is an element inside the queue
 set current indexpath to this element
 
 get prefered width and height of Element
 check if element is a full span or single column element
 
 **** Elements maybe wasting away if there is just on single colum element ***
 **** so we should know how much elements of what kind are available ****
 
 if element is a full span element and colum count is higher than 0
 put fullspan indexpath to queue
 start next iteration but do not increment element counter
 
 if element is an fullspan element
 set x to start position + insets
 set y value to last highest y value inside all columns
 set last y value for all columns to height + insets of element
 set column count to 0
 start next iteration
 
 if element is a single colum element
 detect which column has lowest y value
 set y value
 set x value dependent on column count
 increment stacked column count
 */

//
//  CustomUICollectionViewLayout.m
//  CollectionViewCustomLayout
//
//  Created by Sebastian Boldt on 03.02.15.
//  Copyright (c) 2015 sebastianboldt. All rights reserved.
//

#import "FFXCollectionViewMasonryLayout.h"
// Private Interface
@interface FFXCollectionViewMasonryLayout()

@property (nonatomic, strong) NSMutableArray        *lastYValueForColumns;
@property (nonatomic, strong) NSMutableDictionary   *layoutInfo;            // stores all relevant Information about the CollectionViewCell
@property (nonatomic, strong) NSMutableArray        *fullSpanStack;         // holds all fullspan Elements that didnt fit inside the collectionView
@property (nonatomic,strong)  NSMutableArray * masterStack;

/* temporary Dictionary that stores all Elements after fullSpan like
 row: @(1) --> @[IndexPath1,IndexPath2 ......, IndexPathN]
 row: @(2) --> @[IndexPath1,IndexPath2 ......, IndexPathN]
 row: @(3) --> @[IndexPath1,IndexPath2 ......, IndexPathN] */
@property (nonatomic,strong) NSMutableDictionary * allElementsAfterFullspan;

@end

@implementation FFXCollectionViewMasonryLayout

#pragma mark - UICollectionViewDelegate

// sets intital values
-(void)prepareParameters {
    self.numberOfColums = 2;
    self.interItemSpacing = 2;
    self.allElementsAfterFullspan = [[NSMutableDictionary alloc]init];
    self.fullSpanStack = [[NSMutableArray alloc]init];
    self.layoutInfo = [NSMutableDictionary dictionary];
    [self prepareLastYValueArray];
    [self prepareAllElementsAfterFullSpan];
    [self prepareLastYValueArray];
}

//Creates a Master Stack of all IndexPathes
-(void)prepareMasterStackForSection:(NSInteger)section {
    self.masterStack = [[NSMutableArray alloc]init];
    NSInteger numItems = [self.collectionView numberOfItemsInSection:section];
    for(NSInteger item = 0; item < numItems;item++){
        [self.masterStack insertObject:[NSIndexPath indexPathForItem:item inSection:section] atIndex:self.masterStack.count];
    }
    
}

// Doest inital Calculations for layouting everything
-(void)prepareLayout{
    
    [self prepareParameters];
    CGFloat stackedColumns = 0; // Replace by function that calculates how much costs we have to rescale
    BOOL beforeWasFullSpan = NO;
    // Iterate through all sections
    NSInteger numSections = [self.collectionView numberOfSections];
    for(NSInteger section = 0; section < numSections; section++)  {
        [self prepareMasterStackForSection:section];
        NSIndexPath * nextItem = nil;
        
        // Replace stackedColumns withFunctionsThat calculates how expensive it is to rescale every element
        while ((nextItem = [self getNextElement:!stackedColumns])) {
            
            CGSize size = [self.delegate collectionView:self.collectionView layout:self sizeForItemAtIndexPath:nextItem];
            BOOL isCurrentElementFullspan = [self checkIfElementIsFullSpan:size];
            // If current Element is a fullSpan Element
            if (isCurrentElementFullspan) {
                [self appendFullSpanElement:nextItem beforeWasFullSpan:beforeWasFullSpan];
                stackedColumns = 0; // Column count wieder auf 0 setzen
                beforeWasFullSpan = YES;
            }
            
            else {
                [self appendElement:nextItem];
                beforeWasFullSpan = NO;
                stackedColumns ++;
                if(stackedColumns == self.numberOfColums) {
                    stackedColumns = 0;
                }
            }
        }
    }
}

// Returns next fullspan or single span element
-(NSIndexPath*)getNextElement:(BOOL)allowFullspan {
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
            
            CGSize size = [self.delegate collectionView:self.collectionView layout:self sizeForItemAtIndexPath:tempIndexPath];
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
    
    return indexPath;
}

-(BOOL)collectionViewLayoutShouldRescaleElements:(NSMutableArray*)elements withLastYValues:(NSMutableArray*)lastYValuesForAllColumns{
    /* Getting percentage of how much content of each row is affected when rescaling
     depending on this percentage we should decide to rescale
     The Problem here is that we maybe destroy the order of that element
     and we also need to know if there is an empty element */
     return YES;
}

-(void)appendFullSpanElement:(NSIndexPath*)item beforeWasFullSpan:(BOOL)beforeWasFullSpan {
    if (!beforeWasFullSpan) {
        [self recalculateHeightOfAllElementsAfterFullspan:self.allElementsAfterFullspan];
    }
    UICollectionViewLayoutAttributes * itemAttributes=
    [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:item];
    CGSize size = [self.delegate collectionView:self.collectionView layout:self sizeForItemAtIndexPath:item];
    CGFloat x = self.interItemSpacing;
    CGFloat y = [self highestValueOfAllLastColumns];
    itemAttributes.frame = CGRectMake(x, y,self.collectionView.frame.size.width-self.interItemSpacing*2, size.height); // Aspect Ration stuff has to go here
    itemAttributes.alpha = 0.5;
    y+= size.height;
    y+= self.interItemSpacing;
    self.layoutInfo[item] = itemAttributes;
    [self prepareAllElementsAfterFullSpan];
    [self setLastYValueForAllColums:@(y)];
}

-(void)appendElement:(NSIndexPath*)item {
    UICollectionViewLayoutAttributes * itemAttributes=
    [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:item];
    CGFloat itemWidth = [self getItemWidth];
    NSInteger columnWidthLowestYValue = [self getLastColumnWitLowestYValue];
    CGFloat x = self.interItemSpacing + (self.interItemSpacing + itemWidth) * columnWidthLowestYValue;
    CGFloat y = [[self.lastYValueForColumns objectAtIndex:columnWidthLowestYValue]floatValue];
    CGFloat height = [self.delegate collectionView:self.collectionView layout:self sizeForItemAtIndexPath:item].height;
    itemAttributes.frame = CGRectMake(x, y, itemWidth, height);
    y+= height;
    y+= self.interItemSpacing;
    [self.lastYValueForColumns replaceObjectAtIndex:columnWidthLowestYValue withObject:@(y)];
    self.layoutInfo[item] = itemAttributes;
    NSMutableArray * allElementsAfterFullSpanTemp= [self.allElementsAfterFullspan objectForKey:@(columnWidthLowestYValue)];
    [allElementsAfterFullSpanTemp addObject:item];
}

-(CGFloat)getItemWidth {
    CGFloat fullWidth = self.collectionView.frame.size.width;
    CGFloat availableSpaceExcludingPadding = fullWidth - (self.interItemSpacing * (self.numberOfColums + 1));
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
    if (size.width > self.collectionView.frame.size.width-100) {
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

#pragma mark - Functions to override (UICollectionViewLayout)
// Returns Layoutattributes for Elements in a specific rect
-(NSArray *)layoutAttributesForElementsInRect:(CGRect)rect{
    NSMutableArray *allAttributes = [NSMutableArray arrayWithCapacity:self.layoutInfo.count];
    
    // Schiebe alle Attribute für die Sichtbaren Element in den das Attributarray
    [self.layoutInfo enumerateKeysAndObjectsUsingBlock:^(NSIndexPath *indexPath,
                                                         UICollectionViewLayoutAttributes *attributes,
                                                         BOOL *stop) {
        
        if (CGRectIntersectsRect(rect, attributes.frame)) {
            [allAttributes addObject:attributes];
        }
    }];
    return allAttributes;
}

// Returns the Contentsize for the Whole CollectionView
// Berechne die Höhe des CollectionViews
// Nutzt für die höhen Berechnung den zuletzt gespiecherten Y-Wert
-(CGSize) collectionViewContentSize {
    
    NSUInteger currentColumn = 0;
    CGFloat maxHeight = 0;
    do {
        CGFloat height = [[self.lastYValueForColumns objectAtIndex:currentColumn]doubleValue];
        if(height > maxHeight)
            maxHeight = height;
        currentColumn ++;
    } while (currentColumn < self.numberOfColums);
    
    // Liefere die Größe des CollectionViews zurück
    return CGSizeMake(self.collectionView.frame.size.width, maxHeight);
}
@end

