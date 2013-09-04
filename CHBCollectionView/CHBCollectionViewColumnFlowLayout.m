//
//  CHBColumnFlowLayout.m
//  CHBCollectionView
//
//  Created by Ben Stovold on 03/09/2013.
//  Copyright (c) 2013 Cocoaheads Brisbane. All rights reserved.
//

#import "CHBCollectionViewColumnFlowLayout.h"

static NSString *const CHBColumnFlowLayoutElementKindCell = @"CHBColumnFlowLayoutElementKindCell";

@interface CHBCollectionViewColumnFlowLayout()

@property (nonatomic, assign) NSInteger itemCount;
@property (nonatomic, assign) CGFloat interitemSpacing;
@property (nonatomic, strong) NSMutableArray *columnHeights;
@property (nonatomic, strong) NSDictionary *layoutInfo;

@end

@implementation CHBCollectionViewColumnFlowLayoutAttributes

- (id)copyWithZone:(NSZone *)zone
{
    CHBCollectionViewColumnFlowLayoutAttributes *newAttributes = [super copyWithZone:zone];
    newAttributes.columnIndex = self.columnIndex;
    return newAttributes;
}

@end

@implementation CHBCollectionViewColumnFlowLayout

+ (Class)layoutAttributesClass
{
    return [CHBCollectionViewColumnFlowLayoutAttributes class];
}

#pragma mark - NSObject

- (void)dealloc
{
    [_columnHeights removeAllObjects];
    _columnHeights = nil;
    
    _layoutInfo = nil;
}

- (id)init
{
    self = [super init];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (void)commonInit
{
    // arbitrary defaults
    _numberOfColumns = 2;
    _itemWidth = 148.f;
    _sectionInset = UIEdgeInsetsZero;
    
}

#pragma mark - UICollectionViewLayout

- (void)prepareLayout
{
    NSAssert(self.delegate != nil, @"Column Flow delegate cannot be nil");
    
    [super prepareLayout];
    
    _itemCount = [[self collectionView] numberOfItemsInSection:0];
    NSUInteger sections = [self.collectionView numberOfSections];
    
    NSMutableDictionary *newLayoutInfo = [NSMutableDictionary dictionary];
    NSMutableDictionary *cellLayoutAttributes = [NSMutableDictionary dictionary];
    NSMutableDictionary *headerLayoutAttributes;
    NSMutableDictionary *footerLayoutAttributes;
    
    CGFloat headerHeight = 0.f;
    if ([self.delegate respondsToSelector:@selector(collectionView:layout:referenceHeightForHeaderInSection:)]) {
        headerHeight = [self.delegate collectionView:self.collectionView layout:self referenceHeightForHeaderInSection:0];
    }
    
    _columnHeights = [NSMutableArray arrayWithCapacity:_numberOfColumns];
    for (NSInteger idx = 0; idx < _numberOfColumns; idx++) {
        [_columnHeights addObject:@(_sectionInset.top + headerHeight)];
    }

    _interitemSpacing = (self.collectionView.bounds.size.width - _itemWidth * _numberOfColumns) / (_numberOfColumns + 1);
    
    for (NSInteger idx = 0; idx < _itemCount; idx++) {
        
        NSIndexPath *indexPath = [NSIndexPath indexPathForItem:idx inSection:0];
        
        if (indexPath.item == 0 && headerHeight > 0.f) {
            headerLayoutAttributes = [NSMutableDictionary dictionary];
            UICollectionViewLayoutAttributes *headerAttributes = [UICollectionViewLayoutAttributes layoutAttributesForSupplementaryViewOfKind:UICollectionElementKindSectionHeader withIndexPath:indexPath];
            headerAttributes.frame = CGRectMake(0.f, 0.f, self.collectionViewContentSize.width, headerHeight);
            headerLayoutAttributes[indexPath] = headerAttributes;
        }
        
        CGFloat itemHeight = [self.delegate collectionView:self.collectionView layout:self heightForItemAtIndexPath:indexPath];
        
        NSUInteger columnIndex = [self shortestColumnIndex];
        
        CGFloat xOffset = _interitemSpacing + (_itemWidth + _interitemSpacing) * columnIndex;
        CGFloat yOffset = [(_columnHeights[columnIndex]) floatValue];
        
        CHBCollectionViewColumnFlowLayoutAttributes *attributes = [CHBCollectionViewColumnFlowLayoutAttributes layoutAttributesForCellWithIndexPath:indexPath];
        
        attributes.frame = CGRectMake(xOffset, (sections == 2 && _itemCount == 1) ? 0.0 : yOffset, (sections == 2 && _itemCount == 1) ? self.collectionViewContentSize.width : self.itemWidth, itemHeight);
        attributes.columnIndex = columnIndex;
        
        cellLayoutAttributes[indexPath] = attributes;
        _columnHeights[columnIndex] = @(yOffset + itemHeight + _interitemSpacing);

        if (indexPath.item == _itemCount - 1 && [self.delegate respondsToSelector:@selector(collectionView:layout:referenceHeightForFooterInSection:)]) {
            CGFloat footerHeight = [self.delegate collectionView:self.collectionView layout:self referenceHeightForFooterInSection:0];
            if (footerHeight > 0.f) {
                footerLayoutAttributes = [NSMutableDictionary dictionary];
                UICollectionViewLayoutAttributes *footerAttributes = [UICollectionViewLayoutAttributes layoutAttributesForSupplementaryViewOfKind:UICollectionElementKindSectionFooter withIndexPath:indexPath];
                footerAttributes.frame = CGRectMake(0.f, self.collectionViewContentSize.height - footerHeight, self.collectionViewContentSize.width, footerHeight);
                footerLayoutAttributes[indexPath] = footerAttributes;
            }
        }
    }
    
    newLayoutInfo[CHBColumnFlowLayoutElementKindCell] = cellLayoutAttributes;
    if (headerLayoutAttributes) newLayoutInfo[UICollectionElementKindSectionHeader] = headerLayoutAttributes;
    if (footerLayoutAttributes) newLayoutInfo[UICollectionElementKindSectionFooter] = footerLayoutAttributes;
    
    _layoutInfo = newLayoutInfo;
}

- (CGSize)collectionViewContentSize
{
    if (self.itemCount == 0) {
        return CGSizeZero;
    }

    CGSize contentSize = self.collectionView.frame.size;
    NSUInteger columnIndex = [self longestColumnIndex];
    CGFloat contentHeight = [self.columnHeights[columnIndex] floatValue];
    contentSize.height = contentHeight - self.interitemSpacing + [self footerHeight] + self.sectionInset.bottom;
    return contentSize;
}

- (UICollectionViewLayoutAttributes *)layoutAttributesForItemAtIndexPath:(NSIndexPath *)path
{
    return _layoutInfo[CHBColumnFlowLayoutElementKindCell][path];
}

- (UICollectionViewLayoutAttributes *)layoutAttributesForSupplementaryViewOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    return nil;
}

- (NSArray *)layoutAttributesForElementsInRect:(CGRect)rect
{
    NSMutableArray *allAttributes = [NSMutableArray arrayWithCapacity:self.layoutInfo.count];
    
    [self.layoutInfo enumerateKeysAndObjectsUsingBlock:^(NSString *elementIdentifier, NSDictionary *elementsInfo, BOOL *stop) {
        [elementsInfo enumerateKeysAndObjectsUsingBlock:^(NSIndexPath *indexPath, UICollectionViewLayoutAttributes *attributes, BOOL *innerStop) {
            if (CGRectIntersectsRect(rect, attributes.frame)) {
                [allAttributes addObject:attributes];
            }
        }];
    }];
    
    return allAttributes;
}

#pragma mark - Accessors

- (void)setNumberOfColumns:(NSUInteger)numberOfColumns
{
    if (_numberOfColumns != numberOfColumns) {
        _numberOfColumns = numberOfColumns;
        [self invalidateLayout];
    }
}

- (void)setItemWidth:(CGFloat)itemWidth
{
    if (_itemWidth != itemWidth) {
        _itemWidth = itemWidth;
        [self invalidateLayout];
    }
}

- (void)setSectionInset:(UIEdgeInsets)sectionInset
{
    if (!UIEdgeInsetsEqualToEdgeInsets(_sectionInset, sectionInset)) {
        _sectionInset = sectionInset;
        [self invalidateLayout];
    }
}

#pragma mark - Private Methods

- (NSUInteger)shortestColumnIndex
{
    __block NSUInteger index = 0;
    __block CGFloat shortestHeight = MAXFLOAT;

    [self.columnHeights enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        CGFloat height = [obj floatValue];
        if (height < shortestHeight) {
            shortestHeight = height;
            index = idx;
        }
    }];

    return index;
}

- (NSUInteger)longestColumnIndex
{
    __block NSUInteger index = 0;
    __block CGFloat longestHeight = 0;

    [self.columnHeights enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        CGFloat height = [obj floatValue];
        if (height > longestHeight) {
            longestHeight = height;
            index = idx;
        }
    }];

    return index;
}

- (CGFloat)headerHeight
{
    if ([self.delegate respondsToSelector:@selector(collectionView:layout:referenceHeightForHeaderInSection:)]) {
        return [self.delegate collectionView:self.collectionView layout:self referenceHeightForHeaderInSection:0];
    }
    
    return 0.f;
}

- (CGFloat)footerHeight
{
    if ([self.delegate respondsToSelector:@selector(collectionView:layout:referenceHeightForFooterInSection:)]) {
        return [self.delegate collectionView:self.collectionView layout:self referenceHeightForFooterInSection:0];
    }
    
    return 0.f;
}

@end
