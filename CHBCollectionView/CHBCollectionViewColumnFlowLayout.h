//
//  CHBCollectionViewColumnFlowLayout.h
//  CHBCollectionView
//
//  Created by Ben Stovold on 03/09/2013.
//  Copyright (c) 2013 Cocoaheads Brisbane. All rights reserved.
//

@protocol CHBCollectionViewDelegateColumnLayout;

@interface CHBCollectionViewColumnFlowLayout : UICollectionViewLayout
@property (nonatomic, weak) IBOutlet id<CHBCollectionViewDelegateColumnLayout> delegate;
@property (nonatomic, assign) NSUInteger numberOfColumns;
@property (nonatomic, assign) CGFloat itemWidth;
@property (nonatomic, assign) UIEdgeInsets sectionInset;
@end

@interface CHBCollectionViewColumnFlowLayoutAttributes : UICollectionViewLayoutAttributes

@property (nonatomic, assign) NSUInteger columnIndex;
@property (nonatomic, assign) CGFloat interitemSpacing;

@end

@protocol CHBCollectionViewDelegateColumnLayout <UICollectionViewDelegate>
@required
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(CHBCollectionViewColumnFlowLayout *)collectionViewLayout heightForItemAtIndexPath:(NSIndexPath *)indexPath;
@optional
// NB: column flow layout doesn't yet support more than one section, so section will always be zero
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(CHBCollectionViewColumnFlowLayout *)collectionViewLayout referenceHeightForHeaderInSection:(NSInteger)section;
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(CHBCollectionViewColumnFlowLayout *)collectionViewLayout referenceHeightForFooterInSection:(NSInteger)section;
@end