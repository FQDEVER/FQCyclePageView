//
//  FQCycleFlowLayout.m
//  FQNewCyclePageView
//
//  Created by fanqi on 2018/10/15.
//  Copyright © 2018年 fanqi. All rights reserved.
//

#import "FQCycleFlowLayout.h"
@implementation FQCycleFlowLayout

- (BOOL)shouldInvalidateLayoutForBoundsChange:(CGRect)oldBounds
{
    return YES;
}

- (CGPoint)targetContentOffsetForProposedContentOffset:(CGPoint)proposedContentOffset withScrollingVelocity:(CGPoint)velocity
{
    if (self.scrollDirection == UICollectionViewScrollDirectionHorizontal) {
        CGFloat offsetAdjustment = MAXFLOAT;
        CGFloat horizontalCenter = proposedContentOffset.x + (CGRectGetWidth(self.collectionView.bounds) / 2.0);
        
        CGRect targetRect = CGRectMake(proposedContentOffset.x, 0.0, self.collectionView.bounds.size.width, self.collectionView.bounds.size.height);
        NSArray* array = [super layoutAttributesForElementsInRect:targetRect];
        
        for (UICollectionViewLayoutAttributes* layoutAttributes in array) {
            CGFloat itemHorizontalCenter = layoutAttributes.center.x;
            if (ABS(itemHorizontalCenter - horizontalCenter) < ABS(offsetAdjustment)) {
                offsetAdjustment = itemHorizontalCenter - horizontalCenter;
            }
        }
        return CGPointMake(proposedContentOffset.x + offsetAdjustment, proposedContentOffset.y);
    }else{
        CGFloat offsetAdjustment = MAXFLOAT;
        CGFloat verticalCenter = proposedContentOffset.y + (CGRectGetHeight(self.collectionView.bounds) / 2.0);
        
        CGRect targetRect = CGRectMake(0, proposedContentOffset.y, self.collectionView.bounds.size.width, self.collectionView.bounds.size.height);
        NSArray* array = [super layoutAttributesForElementsInRect:targetRect];
        
        for (UICollectionViewLayoutAttributes* layoutAttributes in array) {
            CGFloat itemVerticalCenter = layoutAttributes.center.y;
            if (ABS(itemVerticalCenter - verticalCenter) < ABS(offsetAdjustment)) {
                offsetAdjustment = itemVerticalCenter - verticalCenter;
            }
        }
        return CGPointMake(proposedContentOffset.x, proposedContentOffset.y + offsetAdjustment);
    }
}

@end
