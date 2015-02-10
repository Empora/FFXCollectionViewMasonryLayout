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
        NSInteger numberOfColumns = 3;
        layoutLogic.interItemSpacing = 10;
        layoutLogic.padding = UIEdgeInsetsMake(0,0,0,0);
        layoutLogic.numberOfColums = numberOfColumns;
        layoutLogic.numberOfItems = [self.collectionView numberOfItemsInSection:section];
        layoutLogic.collectionViewFrame = self.collectionView.frame;
        if(!self.lastYValueForColumns) {
            [self prepareLastYValueArrayForNumberOfColumns:numberOfColumns];
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
-(void)prepareLastYValueArrayForNumberOfColumns:(NSInteger)numberOfColums {
    NSMutableArray *array = [[NSMutableArray alloc]init];
    for (int i = 0; i< numberOfColums; i++) {
        [array addObject:@(0)];
    }
    self.lastYValueForColumns =  array;
}



-(BOOL)collectionViewLayoutShouldRescaleElements:(NSMutableArray*)elements withLastYValues:(NSMutableArray*)lastYValuesForAllColumns{
    /* Getting percentage of how much content of each row is affected when rescaling
     depending on this percentage we should decide to rescale
     The Problem here is that we maybe destroy the order of that element
     and we also need to know if there is an empty element */
     return YES;
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

// Returns the Contentsize for the Whole CollectionView
// Berechne die Höhe des CollectionViews
// Nutzt für die höhen Berechnung den zuletzt gespiecherten Y-Wert
-(CGFloat)highestValueOfAllLastColumns{
    return [[self.lastYValueForColumns valueForKeyPath:@"@max.intValue"] floatValue];
}

-(CGSize) collectionViewContentSize {
    return CGSizeMake(self.collectionView.frame.size.width, [self highestValueOfAllLastColumns] );
}
@end

