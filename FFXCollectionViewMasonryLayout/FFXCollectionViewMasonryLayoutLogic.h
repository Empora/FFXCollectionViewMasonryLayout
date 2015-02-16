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

@property   (nonatomic,assign)      NSInteger numberOfColums;
@property   (nonatomic,assign)      NSInteger numberOfItems;
@property   (nonatomic,assign)      NSInteger interItemSpacing;
@property   (nonatomic,assign)      UIEdgeInsets padding;
@property   (nonatomic, strong)     NSMutableArray *lastYValueForColumns;
@property   (nonatomic,assign)      CGRect collectionViewFrame;

-(NSDictionary*)computeLayoutWithmeasureItemBlock:(FFXMeasureItemBlock)measureItemBlock;


@end
