//
//  FQCyclePageView.h
//  FQNewCyclePageView
//
//  Created by fanqi on 2018/10/15.
//  Copyright © 2018年 fanqi. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class FQCyclePageView;
@protocol FQCycleScrollViewDataSource <NSObject>

@required
/**
 Simulates a data source method. Gets the user's current items

 @param pageView pageView
 @return items count
 */
- (NSInteger)numberOfItemsInPagerView:(FQCyclePageView *)pageView;

/**
 Analog data source methods. Get UICollectionViewCell Object

 @param cycleScrollView pageView
 @param index current Index
 @return cell
 */
- (__kindof UICollectionViewCell *)cycleScrollView:(FQCyclePageView *)cycleScrollView cellForItemAtIndex:(NSInteger)index;

@end

@protocol FQCycleScrollViewDelegate <NSObject>

@optional

/**
 Click on the image callback

 @param cycleScrollView pageView
 @param index selectIndex
 */
- (void)cycleScrollView:(FQCyclePageView *)cycleScrollView didSelectItemAtIndex:(NSInteger)index;


/**
 Picture Scrolling Callback

 @param cycleScrollView pageView
 @param index select Index
 */
- (void)cycleScrollView:(FQCyclePageView *)cycleScrollView didScrollToIndex:(NSInteger)index;

@end


@interface FQCyclePageView : UIView

#pragma mark - Public properties

/**
 The distance between the display view and the left and right side of the screen. Default is 15.0f
 */
@property (nonatomic, assign) CGFloat fq_padding;

/**
 The spacing between item
 */
@property (nonatomic, assign) CGFloat minimumLineSpacing;

/**
 Auto-scrolling interval time, default 2s
 */
@property (nonatomic, assign) CGFloat autoScrollTimeInterval;

/**
 Whether to scroll automatically, default Yes
 */
@property (nonatomic,assign) BOOL autoScroll;

/**
 Whether you can scroll manually, default Yes (for plain text cases)
 */
@property (nonatomic,assign) BOOL scrollEnable;

/**
 Scroll direction, default UICollectionViewScrollDirectionHorizontal
 */
@property (nonatomic, assign) UICollectionViewScrollDirection scrollDirection;

/**
 Starts at the beginning of the specified index and defaults to 0
 */
@property (nonatomic, assign) NSInteger beginIndex;

/**
 Adhere to and implement the specified delegate method
 */
@property (nonatomic, weak) id<FQCycleScrollViewDelegate> delegate;

/**
 Adhere to and implement the specified DataSource method (must be implemented)
 */
@property (nonatomic, weak) id<FQCycleScrollViewDataSource> dataSource;

/**
 Block mode for monitoring clicks
 */
@property (nonatomic, copy) void (^clickItemOperationBlock)(NSInteger currentIndex);

/**
 Block Mode monitoring scrolling
 */
@property (nonatomic, copy) void (^itemDidScrollOperationBlock)(NSInteger currentIndex);


#pragma mark - Public methods

/**
 Overloaded data. Update interface
 */
-(void)reloadData;

/**
 Scroll to the specified index
 */
- (void)makeScrollViewScrollToIndex:(NSInteger)index;

/**
 register pager view cell with class
 */
- (void)registerClass:(Class)Class forCellWithReuseIdentifier:(NSString *)identifier;

/**
 register pager view cell with nib
 */
- (void)registerNib:(UINib *)nib forCellWithReuseIdentifier:(NSString *)identifier;

/**
 dequeue reusable cell for pagerView
 */
- (__kindof UICollectionViewCell *)dequeueReusableCellWithReuseIdentifier:(NSString *)identifier forIndex:(NSInteger)index;

/**
 Pause Current View Carousel scrolling-use when view is about to disappear
 */
-(void)cycleViewWillAppear;

/**
 Start Current View Carousel scrolling-use when view is about to be displayed
 */
-(void)cycleViewWillDisappear;

@end

NS_ASSUME_NONNULL_END
