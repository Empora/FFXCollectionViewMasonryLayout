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
@property (nonatomic,assign) CGFloat yValueAfterFullSpan; // stores Y Value after last full span to know where the new row should start

@end

@implementation FFXCollectionViewMasonryLayout

#pragma mark - UICollectionViewDelegate

// sets intital values
-(void)prepareParameters {
    self.yValueAfterFullSpan = 0;
    self.numberOfColums = 3;
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

-(NSIndexPath*)getNextElement:(BOOL)allowFullspan {
    NSIndexPath * indexPath = nil;
    while (!indexPath) {
        
        BOOL useFullspan = allowFullspan || (self.masterStack.count == 0);
        NSIndexPath * tempIndexPath = nil;
        if (useFullspan && self.fullSpanStack.count){
            tempIndexPath = [self.fullSpanStack objectAtIndex:0];
            [self.fullSpanStack removeObjectAtIndex:0];
        } else if(self.masterStack.count >0){
            
            tempIndexPath = [self.masterStack objectAtIndex:0];
            [self.masterStack removeObjectAtIndex:0];
            
        } else {
            break;
        }
        
        if (useFullspan) {
            indexPath = tempIndexPath;
        } else {
            // Get requested size from delegate
            CGSize size = [self.delegate collectionView:self.collectionView layout:self sizeForItemAtIndexPath:tempIndexPath];
            //and check if Element is a fullspan or not
            BOOL isCurrentElementFullspan = [self checkIfElementIsFullSpan:size];
            if (isCurrentElementFullspan) {
                [self.fullSpanStack addObject:tempIndexPath];
            } else {
                indexPath = tempIndexPath;
            }
        }
    }
    
    return indexPath;
}
// Doest inital Calculations for layouting everything
-(void)prepareLayout{
    
    [self prepareParameters];
    CGFloat stackedColumns = 0;                                                                                 // Stores how much elements stacked allready
    CGFloat fullWidth = self.collectionView.frame.size.width;                                                   // Width of CollectionView
    CGFloat availableSpaceExcludingPadding = fullWidth - (self.interItemSpacing * (self.numberOfColums + 1));   // Available space withput padding
    CGFloat itemWidth = availableSpaceExcludingPadding / self.numberOfColums;                                   // Width of items
    NSInteger numSections = [self.collectionView numberOfSections];                                             // Number of Sections in CollectionView
    
    BOOL beforeWasFullSpan = NO;
    NSIndexPath *indexPath;
    
    // Iterate through all sections
    for(NSInteger section = 0; section < numSections; section++)  {
        [self prepareMasterStackForSection:section];
        NSIndexPath * nextItem = nil;
        while ((nextItem = [self getNextElement:!stackedColumns])) {
            
            
            // Check fullspanStack and try this element first
            indexPath = nextItem;
            // Create the itemAttributes for the appropriate element
            UICollectionViewLayoutAttributes * itemAttributes=
            [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:indexPath];
            
            CGSize size = [self.delegate collectionView:self.collectionView layout:self sizeForItemAtIndexPath:indexPath];
            BOOL isCurrentElementFullspan = [self checkIfElementIsFullSpan:size];
            // If current Element is a fullSpan Element
            if (isCurrentElementFullspan) {
                // and stack colums bigger then 0 & if cell is last cell
                // crashed wenn 2 fullspan hintereinander kommen
                    // If element before was a fullspan element recalculate height of last elements
                if (!beforeWasFullSpan) {
                    [self recalculateHeightOfAllElementsAfterFullspanElement];
                }
                CGFloat x = self.interItemSpacing;
                CGFloat y = [self highestValueOfAllLastColumns];
                itemAttributes.frame = CGRectMake(x, y,self.collectionView.frame.size.width-self.interItemSpacing*2, size.height); // Aspect Ration stuff has to go here
                itemAttributes.alpha = 0.5;
                y+= size.height;
                y+= self.interItemSpacing;
                [self setLastYValueForAllColums:@(y)];
                self.layoutInfo[indexPath] = itemAttributes;
                self.yValueAfterFullSpan = y + size.height;
                stackedColumns = 0; // Column count wieder auf 0 setzen
                [self prepareAllElementsAfterFullSpan];
                [self.masterStack removeObject:indexPath];
                beforeWasFullSpan = YES;
            }
            
            else {
                
                NSInteger columnWidthLowestYValue = [self getLastColumnWitLowestYValue];
                CGFloat x = self.interItemSpacing + (self.interItemSpacing + itemWidth) * columnWidthLowestYValue;
                CGFloat y = [[self.lastYValueForColumns objectAtIndex:columnWidthLowestYValue]floatValue];
                CGFloat height = [self.delegate collectionView:self.collectionView layout:self sizeForItemAtIndexPath:indexPath].height;
                CGFloat width = itemWidth;
                itemAttributes.frame = CGRectMake(x, y, width, height);
                
                y+= height;
                y+= self.interItemSpacing;
                [self.lastYValueForColumns replaceObjectAtIndex:columnWidthLowestYValue withObject:@(y)];
                stackedColumns ++;
                
                if(stackedColumns == self.numberOfColums) {
                    stackedColumns = 0;
                }
                self.layoutInfo[indexPath] = itemAttributes;
                NSMutableArray * tempPointer = [self.allElementsAfterFullspan objectForKey:@(columnWidthLowestYValue)];
                [tempPointer addObject:indexPath];
                beforeWasFullSpan = NO;
                [self.masterStack removeObject:indexPath];
            }
            
            //NSLog(@"MASTER STACK:%@",self.masterStack);
        }
    }
    
    NSLog(@"****************STACK COUNT%lu*****************",(unsigned long)[self.fullSpanStack count]);
}

-(void)recalculateHeightOfAllElementsAfterFullspanElement{
    if ([self.allElementsAfterFullspan count]>0) { // als Paramater
        // Recalculation Stuff
        NSNumber * avgYValue = [self.lastYValueForColumns valueForKeyPath:@"@avg.floatValue"];
        
        for (id key in self.allElementsAfterFullspan) {
            // If it is bigger rescale all cells down
            NSNumber * lastYValueForRow = [self.lastYValueForColumns objectAtIndex:[key integerValue]];
            NSLog(@"LAST Y VALUE FOR ROW:%@",lastYValueForRow);
            NSLog(@"AVG VALUE:%@",avgYValue);
            
            if ([lastYValueForRow floatValue] > [avgYValue floatValue] ) {
                NSLog(@"REDUCE AT %@",key);
                NSMutableArray * indexPathes = [self.allElementsAfterFullspan objectForKey:key];
                int i = 0;
                CGFloat spaceToReduce = ([lastYValueForRow floatValue] -[avgYValue floatValue])/ [indexPathes count];
                // Get through all IndexPathes
                for (NSIndexPath *path in indexPathes) {
                    // Reduce collectionViewCellSize
                    // Teile den Average Wert durch die Anzahl der Zellen und reduziere die Größe
                    NSLog(@"Space to Reduce%f",spaceToReduce);
                    UICollectionViewLayoutAttributes * attributes = self.layoutInfo[path];
                    CGRect newFrame = CGRectMake(attributes.frame.origin.x, attributes.frame.origin.y-(spaceToReduce*(i++)), attributes.frame.size.width, attributes.frame.size.height -spaceToReduce);
                    attributes.frame = newFrame;
                    
                    
                }
            }
            // if it is smaller rescale all cells up
            else {
                // scale up Cell size
                NSLog(@"SCALE UP %@",key);
                NSMutableArray * indexPathes = [self.allElementsAfterFullspan objectForKey:key];
                CGFloat spaceToScaleUp = -([lastYValueForRow floatValue] -[avgYValue floatValue])/ [indexPathes count];
                int i = 0;
                for (NSIndexPath *path in indexPathes) {
                    // Scale up collectionViewCellSize
                    NSLog(@"Space to Scaleup%f",spaceToScaleUp);
                    UICollectionViewLayoutAttributes * attributes = self.layoutInfo[path];
                    CGRect newFrame = CGRectMake(attributes.frame.origin.x, attributes.frame.origin.y+(spaceToScaleUp*i++), attributes.frame.size.width, attributes.frame.size.height +spaceToScaleUp);
                    attributes.frame = newFrame;
                }
            }
            
            
        }
        [self setLastYValueForAllColums:avgYValue];
        [self.allElementsAfterFullspan removeAllObjects];
    }
    
    NSLog(@"**********************");
    
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

