//
//  FFXCollectionViewMasonryLayout.h
//  FFXCollectionViewMasonryLayout
//
//  Created by Sebastian Boldt on 06.02.15.
//  Copyright (c) 2015 Empora. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
@class FFXCollectionViewMasonryLayout;
// This Protocol defines all the Methods the Delegate should implement
@protocol UICollectionViewDelegateFFXMasonryLayout<NSObject>

// This function returns the size of an item at a specific indexPath
@required
- (CGSize) collectionView:(UICollectionView*) collectionView
                   layout:(FFXCollectionViewMasonryLayout*) layout
   sizeForItemAtIndexPath:(NSIndexPath*) indexPath;
@end

@interface FFXCollectionViewMasonryLayout : UICollectionViewLayout
@property(nonatomic,weak) IBOutlet id<UICollectionViewDelegateFFXMasonryLayout> delegate; // delegate that returns size for each Item
@end
