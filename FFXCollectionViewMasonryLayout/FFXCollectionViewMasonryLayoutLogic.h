//
//  FFXCollectionViewMasonryLayoutLogic.h
//  IntegrationOfMasonryLayoutToAdvancedCollectionView
//
//  Created by Sebastian Boldt on 09.02.15.
//  Copyright (c) 2015 Empora. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef CGSize (^FFXMeasureItemBlock)(NSInteger itemIndex,CGRect frame);
@interface FFXCollectionViewMasonryLayoutLogic : NSObject
-(NSArray*)computeLayoutWithNumberOfItems:(NSInteger)numberOfItems
                                  columns:(NSInteger)numerOfColums
                         interItemSpacing:(NSInteger)interItemSpacing
                         measureItemBlock:(FFXMeasureItemBlock)measureItemBlock;
@end
