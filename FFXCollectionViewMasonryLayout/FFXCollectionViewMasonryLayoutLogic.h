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

-(NSDictionary*)computeLayoutWithmeasureItemBlock:(FFXMeasureItemBlock)measureItemBlock;

@property   (nonatomic,assign)      NSInteger numberOfColums;
@property   (nonatomic,assign)      NSInteger numberOfItems;
@property   (nonatomic,assign)      NSInteger section;
@property   (nonatomic,assign)      NSInteger interItemSpacing;
@property   (nonatomic, strong)     NSMutableArray *lastYValueForColumns;
@property   (nonatomic,assign)      CGRect collectionViewFrame;

@end
