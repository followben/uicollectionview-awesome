//
//  CHBCollectionViewStickyHeaderFlowLayout.m
//  CHBCollectionView
//
//  Created by Ben Stovold on 03/09/2013.
//  Copyright (c) 2013 Cocoaheads Brisbane. All rights reserved.
//

#import "CHBStickyHeaderFlowLayout.h"

static CGFloat const CHBStickyHeaderAmount = 80.f;

@implementation CHBStickyHeaderFlowLayout

- (BOOL)shouldInvalidateLayoutForBoundsChange:(CGRect)newBounds
{
    return YES;
}

- (NSArray *)layoutAttributesForElementsInRect:(CGRect)rect
{
    NSMutableArray *attributesArray = [[super layoutAttributesForElementsInRect:rect] mutableCopy];
    
    // Super only returns attributes for headers that are in the bounds,
    // so locate attributes for out of bounds headers and include them in the array
    NSMutableIndexSet *omittedSections = [NSMutableIndexSet indexSet];
    for (UICollectionViewLayoutAttributes *attributes in attributesArray) {
        if (attributes.representedElementCategory == UICollectionElementCategoryCell) {
            [omittedSections addIndex:attributes.indexPath.section];
        }
    }
    for (UICollectionViewLayoutAttributes *attributes in attributesArray) {
        if ([attributes.representedElementKind isEqualToString:UICollectionElementKindSectionHeader]) {
            [omittedSections removeIndex:attributes.indexPath.section];
        }
    }
    [omittedSections enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL *stop) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForItem:0 inSection:idx];
        UICollectionViewLayoutAttributes *attributes = [self layoutAttributesForSupplementaryViewOfKind:UICollectionElementKindSectionHeader
                                                                                            atIndexPath:indexPath];
        [attributesArray addObject:attributes];
    }];
    
    for (UICollectionViewLayoutAttributes *attributes in attributesArray) {
        
        if ([attributes.representedElementKind isEqualToString:UICollectionElementKindSectionHeader]) {
            
            NSInteger section = attributes.indexPath.section;
            NSInteger numberOfItemsInSection = [self.collectionView numberOfItemsInSection:section];
            
            NSIndexPath *firstCellIndexPath = [NSIndexPath indexPathForItem:0 inSection:section];
            NSIndexPath *lastCellIndexPath = [NSIndexPath indexPathForItem:MAX(0, (numberOfItemsInSection - 1)) inSection:section];
            
            if (numberOfItemsInSection > 1) {
                UICollectionViewLayoutAttributes *firstCellAttrs = [self layoutAttributesForItemAtIndexPath:firstCellIndexPath];
                UICollectionViewLayoutAttributes *lastCellAttrs = [self layoutAttributesForItemAtIndexPath:lastCellIndexPath];
                
                CGFloat headerHeight = CGRectGetHeight(attributes.frame);
                CGPoint origin = attributes.frame.origin;
                
                origin.y = MIN(MAX(self.collectionView.contentOffset.y - headerHeight + CHBStickyHeaderAmount, CGRectGetMinY(firstCellAttrs.frame) - headerHeight - self.sectionInset.top), (CGRectGetMaxY(lastCellAttrs.frame) - headerHeight));
                
                attributes.zIndex = 1024;
                attributes.frame = (CGRect){.origin = origin, .size = attributes.frame.size};
            }
        }
        
    }
    
    return attributesArray;
}

@end
