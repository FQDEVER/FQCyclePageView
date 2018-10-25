//
//  FQ_CycleCollectionCell.m
//  FQNewCyclePageView
//
//  Created by fanqi on 2018/10/15.
//  Copyright © 2018年 fanqi. All rights reserved.
//

#import "FQ_CycleCollectionCell.h"

@interface FQ_CycleCollectionCell()
@property (nonatomic, strong) UIImageView *imgView;

@property (nonatomic, strong) UILabel *currentLabel;
@end

@implementation FQ_CycleCollectionCell

-(instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        [self.contentView addSubview:self.imgView];
        self.imgView.frame = self.contentView.bounds;
        self.contentView.clipsToBounds = YES;
        self.imgView.layer.masksToBounds = YES;
        self.imgView.layer.cornerRadius = 15.0;
        
        [self.contentView addSubview:self.currentLabel];
        self.currentLabel.frame = self.contentView.bounds;
    }
    return self;
}

-(UIImageView *)imgView
{
    if (!_imgView) {
        _imgView = [[UIImageView alloc]init];
    }
    return _imgView;
}

-(UILabel *)currentLabel
{
    if (!_currentLabel) {
        _currentLabel = [[UILabel alloc]init];
        _currentLabel.textColor = UIColor.redColor;
    }
    return _currentLabel;
}

-(void)setImgStr:(NSString *)imgStr
{
    _imgStr = imgStr;
    _imgView.image = [UIImage imageNamed:imgStr];
}

-(void)setIndex:(NSInteger)index
{
    _index = index;
    _currentLabel.text = @(index).stringValue;
}

@end
