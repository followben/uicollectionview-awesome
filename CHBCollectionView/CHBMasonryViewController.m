//
//  CHBMasonryViewController.m
//  CHBCollectionView
//
//  Created by Ben Stovold on 03/09/2013.
//  Copyright (c) 2013 Cocoaheads Brisbane. All rights reserved.
//

#import "CHBMasonryViewController.h"
#import "CHBCollectionViewColumnFlowLayout.h"

@interface CHBMasonryViewController () <CHBCollectionViewDelegateColumnLayout>

@end

@implementation CHBMasonryViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    CHBCollectionViewColumnFlowLayout *layout = (CHBCollectionViewColumnFlowLayout *)self.collectionViewLayout;
    layout.sectionInset = UIEdgeInsetsMake(8.f, 8.f, 8.f, 8.f);
    layout.numberOfColumns = 2;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return 21;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"MyCell" forIndexPath:indexPath];
    
    return cell;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(CHBCollectionViewColumnFlowLayout *)collectionViewLayout heightForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return 64 + arc4random() % 100;
}

@end
