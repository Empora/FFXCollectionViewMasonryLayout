
//  ViewController.m
//  CollectionViewCustomLayout
//
//  Created by Sebastian Boldt on 03.02.15.
//  Copyright (c) 2015 sebastianboldt. All rights reserved.
//

#import "ViewController.h"
#import "FFXCollectionViewMasonryLayout.h"
// Our Controller is delegate and Datasourcef ro the CollectionView
// And it is delegate for the CustomCollectionViewLayout
@interface ViewController () <UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFFXMasonryLayout>
@property(nonatomic,strong)IBOutlet UICollectionView * collectionView;
@property (nonatomic,strong) NSMutableArray * testModel;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupTestModel]; // Creates some TestData
    [self setupCollectionView];
    [self.collectionView reloadData];
}

-(void)setupCollectionView {
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UICollectionViewDatasource 

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"cell";
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:CellIdentifier
                                                                           forIndexPath:indexPath];
    cell.backgroundColor = [UIColor redColor];
    UILabel * textLabel = (UILabel*)[cell viewWithTag:1];
    [textLabel setText:[NSString stringWithFormat:@"%ld",(long)indexPath.row]];
    return cell;
}

// Returns number of Items in Section
-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return [self.testModel count];
}

// Returns Sections to display in CollectionView
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    return 1;
}

#pragma mark - CustomCollectionViewDelegate
- (CGSize) collectionView:(UICollectionView*) collectionView
                   layout:(FFXCollectionViewMasonryLayout*) layout
   sizeForItemAtIndexPath:(NSIndexPath*) indexPath {
    // Creates random items for fullspan and normal items
    NSString * string = [self.testModel objectAtIndex:indexPath.row];
    if ([string isEqualToString:@"A"]) { // fullspan
        CGSize temp = CGSizeMake(self.collectionView.frame.size.width, 200 + (arc4random() % 10));
       return temp;
    } else {
        // Random string
        CGSize temp = CGSizeMake(self.collectionView.frame.size.width/2, 100 + (arc4random() % 400));
        return temp;
    }
}

// Test Data stuff
-(NSNumber *)randomNumberFromRangeMax:(NSInteger)aMax Min:(NSInteger)aMin
{
    return [NSNumber numberWithInt:(int)(rand() % (aMax - aMin + 1) + aMin)];
}

// Creates some Testdata A stands for
-(void)setupTestModel {
    self.testModel = [[NSMutableArray alloc]init];
    //Create some TestData
    for (int i = 0 ; i <100; i++) {
        int r = arc4random() % 5; // 5 different Kinds of Elements
        if (r == 1) {
            [self.testModel addObject:@"A"]; // A is Fullspan
        } else [self.testModel addObject:@"B"]; // B is Random element
    }
    
    /*
    [self.testModel addObject:@"B"];
    [self.testModel addObject:@"A"];
    [self.testModel addObject:@"A"];
    [self.testModel addObject:@"A"];*/
}

-(void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator{
    [self.collectionView.collectionViewLayout invalidateLayout];
}

#pragma mark - barbuttonItem

-(IBAction)refresh:(id)sender{
    [self.collectionView.collectionViewLayout invalidateLayout];
}
@end
