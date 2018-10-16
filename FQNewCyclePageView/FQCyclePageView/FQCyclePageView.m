//
//  FQCyclePageView.m
//  FQNewCyclePageView
//
//  Created by fanqi on 2018/10/15.
//  Copyright © 2018年 fanqi. All rights reserved.
//

#import "FQCyclePageView.h"
#import "FQCycleFlowLayout.h"

@interface FQCyclePageView()<UICollectionViewDataSource, UICollectionViewDelegate>
{
    struct {
        unsigned int didScrollToIndex   :1;
        unsigned int didSelectItemAtIndex :1;
    }_delegateFlags;
    struct {
        unsigned int cellForItemAtIndex   :1;
    }_dataSourceFlags;
}

/**
 collectionView
 */
@property (nonatomic, weak) UICollectionView *mainView;

/**
 Section under current collection
 */
@property (nonatomic, assign) NSInteger dequeueSection;

/**
 Total Items Quantity
 */
@property (nonatomic, assign) NSInteger totalItemsCount;

/**
 Number of source data
 */
@property (nonatomic, assign) NSInteger originItemsCount;

/**
 flow layout style
 */
@property (nonatomic, strong) FQCycleFlowLayout *flowLayout;

/**
 timer
 */
@property (nonatomic, weak) NSTimer *timer;

@end

@implementation FQCyclePageView

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        [self setupMainView];
        [self initialization];
    }
    return self;
}


- (void)setupMainView
{
    _flowLayout = [[FQCycleFlowLayout alloc]init];
    _flowLayout.itemSize = CGSizeMake(self.bounds.size.width - 30, self.bounds.size.height);
    _flowLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    _flowLayout.minimumLineSpacing = 10;
    _flowLayout.sectionInset = UIEdgeInsetsMake(0, 15, 0, 15);
    
    UICollectionView *mainView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.height) collectionViewLayout:_flowLayout];
    mainView.backgroundColor = [UIColor clearColor];
    mainView.decelerationRate = UIScrollViewDecelerationRateFast;
    mainView.dataSource = self;
    mainView.delegate = self;
    mainView.showsHorizontalScrollIndicator = NO;
    mainView.showsVerticalScrollIndicator = NO;
    [self addSubview:mainView];
    _mainView = mainView;
    
    self.beginIndex = 0;
}

- (void)initialization
{
    self.autoScrollTimeInterval = 2.0;
    self.autoScroll = YES;
    self.dequeueSection = 0;
    self.backgroundColor = [UIColor whiteColor];
}


-(UICollectionViewScrollPosition)getScrollPositionCentered{
    return _flowLayout.scrollDirection == UICollectionViewScrollDirectionHorizontal ? UICollectionViewScrollPositionCenteredHorizontally : UICollectionViewScrollPositionCenteredVertically;
}

#pragma mark - Set

-(void)setMinimumLineSpacing:(CGFloat)minimumLineSpacing
{
    _minimumLineSpacing = minimumLineSpacing;
    _flowLayout.minimumLineSpacing = minimumLineSpacing;
}

-(void)setFq_padding:(CGFloat)fq_padding{
    _fq_padding = fq_padding;
    _flowLayout.itemSize = CGSizeMake(self.bounds.size.width - 2 * fq_padding, self.bounds.size.height);
    _flowLayout.sectionInset = UIEdgeInsetsMake(0, fq_padding, 0, fq_padding);
}

-(void)setBeginIndex:(NSInteger)beginIndex
{
    _beginIndex = beginIndex;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self makeScrollViewScrollToIndex:self.beginIndex];
    });
}

-(void)setAutoScroll:(BOOL)autoScroll{
    _autoScroll = autoScroll;
    
    [self invalidateTimer];
    
    if (_autoScroll) {
        [self setupTimer];
    }
}

- (void)setScrollDirection:(UICollectionViewScrollDirection)scrollDirection
{
    _scrollDirection = scrollDirection;
    
    _flowLayout.scrollDirection = scrollDirection;
}

- (void)setAutoScrollTimeInterval:(CGFloat)autoScrollTimeInterval
{
    _autoScrollTimeInterval = autoScrollTimeInterval;
    
    [self setAutoScroll:self.autoScroll];
}

- (void)setDelegate:(id<FQCycleScrollViewDelegate>)delegate
{
    _delegate = delegate;
    
    _delegateFlags.didScrollToIndex = [delegate respondsToSelector:@selector(cycleScrollView:didScrollToIndex:)];
    _delegateFlags.didSelectItemAtIndex = [delegate respondsToSelector:@selector(cycleScrollView:didSelectItemAtIndex:)];
}


- (void)setDataSource:(id<FQCycleScrollViewDataSource>)dataSource {
    _dataSource = dataSource;
    _dataSourceFlags.cellForItemAtIndex = [dataSource respondsToSelector:@selector(cycleScrollView:cellForItemAtIndex:)];
}

-(void)setScrollEnable:(BOOL)scrollEnable
{
    _scrollEnable = scrollEnable;
    self.mainView.scrollEnabled = scrollEnable;
}

#pragma mark - Timer

- (void)setupTimer
{
    [self invalidateTimer];
    
    NSTimer *timer = [NSTimer scheduledTimerWithTimeInterval:self.autoScrollTimeInterval target:self selector:@selector(automaticScroll) userInfo:nil repeats:YES];
    _timer = timer;
    [[NSRunLoop mainRunLoop] addTimer:timer forMode:NSRunLoopCommonModes];
}

- (void)invalidateTimer
{
    [_timer invalidate];
    _timer = nil;
}

- (void)automaticScroll
{
    if (_originItemsCount == 0 || _originItemsCount == 1 ) return;
    int currentIndex = [self currentIndex];
    int targetIndex = currentIndex + 1;
    [self scrollToIndex:targetIndex];
}

- (void)scrollToIndex:(int)targetIndex
{
    /*
     The number of 20 * _originitemscount is reserved, and the user can swipe manually without switching.
     */
    if (targetIndex >= _totalItemsCount - _originItemsCount * 20 && targetIndex < _totalItemsCount) {
        
        [_mainView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:targetIndex inSection:0] atScrollPosition:[self getScrollPositionCentered] animated:YES];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self->_mainView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:self->_totalItemsCount * 0.5 + (targetIndex % self->_originItemsCount) inSection:0] atScrollPosition:[self getScrollPositionCentered] animated:NO];
        });
        
    }else if(targetIndex >= _totalItemsCount){
        targetIndex = _totalItemsCount * 0.5;
        [_mainView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:targetIndex inSection:0] atScrollPosition:[self getScrollPositionCentered] animated:NO];
        int indexOnPageControl = [self pageControlIndexWithCurrentCellIndex:targetIndex];
        if (_delegateFlags.didScrollToIndex) {
            [self.delegate cycleScrollView:self didScrollToIndex:indexOnPageControl];
        } else if (self.itemDidScrollOperationBlock) {
            self.itemDidScrollOperationBlock(indexOnPageControl);
        }
    }else{
        [_mainView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:targetIndex inSection:0] atScrollPosition:[self getScrollPositionCentered] animated:YES];
    }
}

- (int)currentIndex
{
    if (_mainView.bounds.size.width == 0 || _mainView.bounds.size.height == 0) {
        return 0;
    }
    
    int index = 0;
    if (_flowLayout.scrollDirection == UICollectionViewScrollDirectionHorizontal) {
        index = (_mainView.contentOffset.x) / (_flowLayout.itemSize.width + _flowLayout.minimumLineSpacing);
    } else {
        index = (_mainView.contentOffset.y) / (_flowLayout.itemSize.height + _flowLayout.minimumLineSpacing);
    }
    
    return MAX(0, index);
}

- (int)pageControlIndexWithCurrentCellIndex:(NSInteger)index
{
    return (int)index % self.originItemsCount;
}

#pragma mark - UICollectionViewDataSource


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    self.originItemsCount = [_dataSource numberOfItemsInPagerView:self];
    /*
     Using CollectionView reuse mechanism
     */
    _totalItemsCount = self.originItemsCount > 1 ? self.originItemsCount * 1000 : self.originItemsCount;
    return _totalItemsCount;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    _dequeueSection = indexPath.section;
    if (_dataSourceFlags.cellForItemAtIndex) {
        return [_dataSource cycleScrollView:self cellForItemAtIndex:[self pageControlIndexWithCurrentCellIndex:indexPath.row]];
    }
    NSAssert(NO, @"pagerView cellForItemAtIndex: is nil!");
    return nil;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (_delegateFlags.didSelectItemAtIndex) {
        [self.delegate cycleScrollView:self didSelectItemAtIndex:[self pageControlIndexWithCurrentCellIndex:indexPath.item]];
    }
    
    if (_clickItemOperationBlock) {
        _clickItemOperationBlock([self pageControlIndexWithCurrentCellIndex:indexPath.item]);
    }
}

#pragma mark - User Action Methods

/**
 Called when the user starts dragging
 */
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    if (self.autoScroll) {
        [self invalidateTimer];
    }
}

/**
 When the user ends the drag and is called, when Decelerate is YES, the end of the drag will have a deceleration process. Note that after didenddragging, if there is a deceleration process, the dragging of scroll view is not immediately set to no, but until the deceleration is over, so the actual semantics of this dragging attribute are closer to scrolling.
 */
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    if (self.autoScroll) {
        [self setupTimer];
    }
}

/**
  Slow motion is called at the end of the animation to ensure that the manual slide will not go to the final situation
 */
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    int targetIndex = [self currentIndex];
  
    [_mainView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:_totalItemsCount * 0.5 + (targetIndex % _originItemsCount) inSection:0] atScrollPosition:[self getScrollPositionCentered] animated:NO];
}

/**
 The end scrolling animation is called.
 */
- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView
{
    if (!self.totalItemsCount) return;
    int itemIndex = [self currentIndex];
    int indexOnPageControl = [self pageControlIndexWithCurrentCellIndex:itemIndex];
    
    /*
     Prevents the end of scrolling from scrolling to the specified position
     */
    if (_flowLayout.scrollDirection == UICollectionViewScrollDirectionHorizontal) {
        CGFloat offsetX = scrollView.contentOffset.x;
        CGFloat needOffsetX = itemIndex * (_flowLayout.itemSize.width + _minimumLineSpacing);
        if (offsetX > needOffsetX) {
            [self scrollToIndex:itemIndex + 1];
            indexOnPageControl = [self pageControlIndexWithCurrentCellIndex:itemIndex + 1];
        }else if (offsetX < needOffsetX){
            [self scrollToIndex:itemIndex - 1];
            indexOnPageControl = [self pageControlIndexWithCurrentCellIndex:itemIndex - 1];
        }
    }else{
        CGFloat offsetY = scrollView.contentOffset.y;
        CGFloat needOffsetY = itemIndex * (_flowLayout.itemSize.height + _minimumLineSpacing);
        if (offsetY > needOffsetY) {
            [self scrollToIndex:itemIndex + 1];
            indexOnPageControl = [self pageControlIndexWithCurrentCellIndex:itemIndex + 1];
        }else if (offsetY < needOffsetY){
            [self scrollToIndex:itemIndex - 1];
            indexOnPageControl = [self pageControlIndexWithCurrentCellIndex:itemIndex - 1];
        }
    }
    
    if (_delegateFlags.didScrollToIndex) {
        [self.delegate cycleScrollView:self didScrollToIndex:indexOnPageControl];
    } else if (_itemDidScrollOperationBlock) {
        _itemDidScrollOperationBlock(indexOnPageControl);
    }
}

/**
 This method was introduced from IOS 5 and was called before didenddragging, when the velocity in the Willenddragging method was Cgpointzero (no speed in two directions at the end of the drag), Didenddragging Decele Rate is no, that is, there is no deceleration process, and willbegindecelerating and didenddecelerating are not called. Conversely, when velocity is not cgpointzero, scroll view slows down to targetcontentoffset with velocity as the initial velocity.
 It is important to note that the targetcontentoffset here is a pointer, yes, you can change the deceleration movement of the destination, which is very useful in the implementation of some effects, the example will be specific to the use of the chapter, and other implementation methods to compare. Typically used to calculate the final offset value
 */
- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset{

    if (!self.totalItemsCount) return;
    int currentIndex = 0;
    if (_flowLayout.scrollDirection == UICollectionViewScrollDirectionHorizontal) {
        CGFloat offsetX = targetContentOffset->x;
        currentIndex = offsetX / (_flowLayout.itemSize.width + _flowLayout.minimumLineSpacing);
        
    }else{
        CGFloat offsetY = targetContentOffset->y;
        currentIndex = offsetY / (_flowLayout.itemSize.height + _flowLayout.minimumLineSpacing);
    }
   
    int indexOnPageControl = [self pageControlIndexWithCurrentCellIndex:currentIndex];

    if (_delegateFlags.didScrollToIndex) {
        [self.delegate cycleScrollView:self didScrollToIndex:indexOnPageControl];
    } else if (self.itemDidScrollOperationBlock) {
        self.itemDidScrollOperationBlock(indexOnPageControl);
    }
    
}

#pragma mark - Public external methods

- (void)registerClass:(Class)Class forCellWithReuseIdentifier:(NSString *)identifier {
    [_mainView registerClass:Class forCellWithReuseIdentifier:identifier];
}

- (void)registerNib:(UINib *)nib forCellWithReuseIdentifier:(NSString *)identifier {
    [_mainView registerNib:nib forCellWithReuseIdentifier:identifier];
}

- (__kindof UICollectionViewCell *)dequeueReusableCellWithReuseIdentifier:(NSString *)identifier forIndex:(NSInteger)index {
    UICollectionViewCell *cell = [_mainView dequeueReusableCellWithReuseIdentifier:identifier forIndexPath:[NSIndexPath indexPathForItem:index inSection:_dequeueSection]];
    return cell;
}

-(void)reloadData{
    [_mainView reloadData];
}

- (void)makeScrollViewScrollToIndex:(NSInteger)index{
    if (self.autoScroll) {
        [self invalidateTimer];
    }
    if (0 == _totalItemsCount) return;

     [_mainView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:(int)(_totalItemsCount * 0.5 + index) inSection:0] atScrollPosition:[self getScrollPositionCentered] animated:NO];
    int indexOnPageControl = [self pageControlIndexWithCurrentCellIndex:index];
    if (_delegateFlags.didScrollToIndex) {
        [self.delegate cycleScrollView:self didScrollToIndex:indexOnPageControl];
    } else if (self.itemDidScrollOperationBlock) {
        self.itemDidScrollOperationBlock(indexOnPageControl);
    }

    if (self.autoScroll) {
        [self setupTimer];
    }
}


/**
 Pause Current View Carousel scrolling-use when view is about to disappear
 */
-(void)cycleViewWillAppear
{
    if (_autoScroll) {
        [self setupTimer];
        [self adjustWhenControllerViewWillAppera];
    }
}

/**
 Start Current View Carousel scrolling-use when view is about to be displayed
 */
-(void)cycleViewWillDisappear
{
    if (_autoScroll) {
        [self invalidateTimer];
        [self adjustWhenControllerViewWillAppera];
    }
}

/**
 When resolving viewwillappear when a carousel card is in half the problem, call this method when the controller viewwillappear
 */
- (void)adjustWhenControllerViewWillAppera
{
    long targetIndex = [self currentIndex];
    if (targetIndex < _totalItemsCount) {
        [_mainView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:targetIndex inSection:0] atScrollPosition:[self getScrollPositionCentered] animated:NO];
        
        int indexOnPageControl = [self pageControlIndexWithCurrentCellIndex:targetIndex];
        if (_delegateFlags.didScrollToIndex) {
            [self.delegate cycleScrollView:self didScrollToIndex:indexOnPageControl];
        } else if (self.itemDidScrollOperationBlock) {
            self.itemDidScrollOperationBlock(indexOnPageControl);
        }
    }
}

#pragma mark - dealloc

/**
 Resolves an issue in which the current view cannot be released because it is strongly referenced by a timer when the parent view is released
 */
- (void)willMoveToSuperview:(UIView *)newSuperview
{
    if (!newSuperview) {
        [self invalidateTimer];
    }
}

/**
 Resolves a crash when accessing a wild pointer when a timer is released after the callback Scrollviewdidscroll
 */
- (void)dealloc {
    _mainView.delegate = nil;
    _mainView.dataSource = nil;
    _delegate = nil;
    _dataSource = nil;
}

@end
