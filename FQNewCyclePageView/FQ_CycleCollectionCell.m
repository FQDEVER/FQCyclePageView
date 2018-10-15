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

-(void)setImgStr:(NSString *)imgStr
{
    _imgStr = imgStr;
    _imgView.image = [UIImage imageNamed:imgStr];
}


@end
