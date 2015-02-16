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
#import "FFXCollectionViewMasonryLayoutLogic.h"
// Private Interface
@interface FFXCollectionViewMasonryLayout()

@property (nonatomic, strong) NSMutableArray        *layoutInfo;            // stores all relevant Information about the CollectionViewCell
@property (nonatomic, strong) NSMutableArray        *lastYValueForColumns;
@end

@implementation FFXCollectionViewMasonryLayout

#pragma mark - UICollectionViewDelegate

// sets intital values
-(void)prepareParameters {
    self.layoutInfo = [[NSMutableArray alloc]init];
}

// Doest inital Calculations for layouting everything
-(void)prepareLayout{
    
    [self prepareParameters];
    
    // Iterate through all sections
    NSInteger numSections = [self.collectionView numberOfSections];
    for(NSInteger section = 0; section < numSections; section++)  {
        
        FFXCollectionViewMasonryLayoutLogic * layoutLogic =[[FFXCollectionViewMasonryLayoutLogic alloc]init];
        NSInteger numberOfColumns = 2;
        layoutLogic.interItemSpacing = 5;
        layoutLogic.padding = UIEdgeInsetsMake(8,8,8,8); // top,left, bottom, right
        layoutLogic.numberOfColums = numberOfColumns;
        layoutLogic.numberOfItems = [self.collectionView numberOfItemsInSection:section];
        layoutLogic.collectionViewFrame = CGRectMake(0, 0, self.collectionView.frame.size.width,0);
        if(!self.lastYValueForColumns) {
            self.lastYValueForColumns = [self prepareLastYValueArrayForNumberOfColumns:numberOfColumns withValue:@(100)];
        }
        layoutLogic.lastYValueForColumns = self.lastYValueForColumns;

        NSDictionary * layoutAttributes = [layoutLogic computeLayoutWithmeasureItemBlock:^CGSize(NSInteger itemIndex,CGRect frame){
            CGSize itemSize = [self.delegate collectionView:self.collectionView layout:self sizeForItemAtIndexPath:[NSIndexPath indexPathForItem:itemIndex inSection:section]];
            return itemSize;
        }];
        [self.layoutInfo addObjectsFromArray:[layoutAttributes allValues]];
    }
}

// creates an Array with same dimensions as number of columns and initalizes its values with 0 (start point)
-(NSMutableArray*)prepareLastYValueArrayForNumberOfColumns:(NSInteger)numberOfColums withValue:(NSNumber*)value {
    NSMutableArray *array = [[NSMutableArray alloc]init];
    for (int i = 0; i< numberOfColums; i++) {
        [array addObject:value];
    }
    return array;
}

#pragma mark - Functions to override (UICollectionViewLayout)
// Returns Layoutattributes for Elements in a specific rect
-(NSArray *)layoutAttributesForElementsInRect:(CGRect)rect{
    NSMutableArray *allAttributes = [NSMutableArray arrayWithCapacity:self.layoutInfo.count];
    for (UICollectionViewLayoutAttributes * attributes in self.layoutInfo) {
        if (CGRectIntersectsRect(rect, attributes.frame)) {
            [allAttributes addObject:attributes];
        }
    }
    return allAttributes;
}

// Returns the Contentsize for the whole CollectionView
// Berechne die Höhe des CollectionViews
// Nutzt für die höhen Berechnung den zuletzt gespiecherten Y-Wert
-(CGFloat)highestValueOfAllLastColumns{
    return [[self.lastYValueForColumns valueForKeyPath:@"@max.intValue"] floatValue];
}

-(CGSize) collectionViewContentSize {
    return CGSizeMake(self.collectionView.frame.size.width, [self highestValueOfAllLastColumns] );
}
@end

