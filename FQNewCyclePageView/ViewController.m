//
//  ViewController.m
//  FQNewCyclePageView
//
//  Created by fanqi on 2018/10/15.
//  Copyright © 2018年 fanqi. All rights reserved.
//

#import "ViewController.h"
#import "FQCyclePageView.h"
#import "FQPageControl.h"
#import "FQ_CycleCollectionCell.h"
#import "FQ_TextCycleCollectionCell.h"

@interface ViewController ()<FQCycleScrollViewDelegate,FQCycleScrollViewDataSource>

@property (nonatomic, strong) FQCyclePageView *pagerView;

@property (nonatomic, strong) FQPageControl*pageControl;

@property (nonatomic, strong) FQCyclePageView *textPagerView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.view.backgroundColor = [UIColor orangeColor];
    
#pragma mark - 方案1 .图片的样式
    [self addPagerView];
    [self addPageControl];
    
#pragma mark - 方案2 .文本样式
    [self addTextPagerView];
    
}

- (void)addPagerView {
    
    FQCyclePageView *pagerView = [[FQCyclePageView alloc]initWithFrame:CGRectMake(0, 100, self.view.bounds.size.width, 180)];
    pagerView.fq_padding = 0.0;
    pagerView.minimumLineSpacing = 20;
    pagerView.backgroundColor = [UIColor whiteColor];
    pagerView.autoScrollTimeInterval = 3.0;
    pagerView.autoScroll = YES;
    pagerView.dataSource = self;
    pagerView.delegate = self;
    pagerView.scrollDirection = UICollectionViewScrollDirectionVertical;
    [pagerView registerClass:[FQ_CycleCollectionCell class] forCellWithReuseIdentifier:@"FQ_CycleCollectionCellID"];
    self.pagerView = pagerView;
    [self.view addSubview:self.pagerView];

}

- (void)addTextPagerView {
    
    FQCyclePageView *pagerView = [[FQCyclePageView alloc]initWithFrame:CGRectMake(0, 300, 200, 40)];
    pagerView.fq_padding = 15.0;
    pagerView.minimumLineSpacing = 10;
    pagerView.backgroundColor = [UIColor whiteColor];
    pagerView.autoScrollTimeInterval = 3.0;
    pagerView.autoScroll = YES;
    pagerView.dataSource = self;
    pagerView.delegate = self;
    pagerView.scrollEnable = NO;
    pagerView.scrollDirection = UICollectionViewScrollDirectionVertical;
    [pagerView registerClass:[FQ_TextCycleCollectionCell class] forCellWithReuseIdentifier:@"FQ_TextCycleCollectionCellID"];
    self.textPagerView = pagerView;
    [self.view addSubview:self.textPagerView];
    
}

- (void)addPageControl {
    
    FQPageControl *pageControl = [[FQPageControl alloc]initWithFrame:CGRectMake(0, CGRectGetMaxY(self.pagerView.frame) - 20, self.view.bounds.size.width, 20)];
    pageControl.currentPageIndicatorSize = CGSizeMake(16, 16);
    pageControl.pageIndicatorImage = [UIImage imageNamed:@"ios_pagecontroll_normal"];
    pageControl.currentPageIndicatorImage = [UIImage imageNamed:@"ios_pagecontroll_select"];
    self.pageControl = pageControl;
    [self.view addSubview:self.pageControl];
}


-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [self.pagerView makeScrollViewScrollToIndex:2];
}

- (NSInteger)numberOfItemsInPagerView:(FQCyclePageView *)pageView {
    self.pageControl.numberOfPages = 2;
    return 2;
}

- (__kindof UICollectionViewCell *)cycleScrollView:(FQCyclePageView *)cycleScrollView cellForItemAtIndex:(NSInteger)index {
    if ([cycleScrollView isEqual:self.pagerView]) {
        FQ_CycleCollectionCell *cell = [cycleScrollView dequeueReusableCellWithReuseIdentifier:@"FQ_CycleCollectionCellID" forIndex:index];
        cell.imgStr = @(index % 3 + 1).stringValue;
        cell.index = index;
        return cell;
    }else{
        FQ_TextCycleCollectionCell *cell = [cycleScrollView dequeueReusableCellWithReuseIdentifier:@"FQ_TextCycleCollectionCellID" forIndex:index];
        cell.textStr = [NSString stringWithFormat:@"%@在做什么",@(index % 3 + 1)];
        return cell;
    }
}

/** 点击图片回调 */
- (void)cycleScrollView:(FQCyclePageView *)cycleScrollView didSelectItemAtIndex:(NSInteger)index
{
    NSLog(@"--xxxxx-------%zd",index);
}

/** 图片滚动回调 */
- (void)cycleScrollView:(FQCyclePageView *)cycleScrollView didScrollToIndex:(NSInteger)index
{
    if ([cycleScrollView isEqual:self.pagerView]) {
        self.pageControl.currentPage =  index;
    }
}


@end
