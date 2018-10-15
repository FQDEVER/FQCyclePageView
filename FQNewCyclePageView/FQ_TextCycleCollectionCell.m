//
//  FQ_TextCycleCollectionCell.m
//  FQNewCyclePageView
//
//  Created by fanqi on 2018/10/15.
//  Copyright © 2018年 fanqi. All rights reserved.
//

#import "FQ_TextCycleCollectionCell.h"

@interface FQ_TextCycleCollectionCell()

@property (nonatomic, strong) UILabel *textlabel;

@end

@implementation FQ_TextCycleCollectionCell

-(instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        
        [self.contentView addSubview:self.textlabel];

        self.textlabel.frame = self.contentView.bounds;
      
        self.contentView.clipsToBounds = YES;
    }
    return self;
}

-(UILabel *)textlabel
{
    if (!_textlabel) {
        _textlabel = [[UILabel alloc]init];
        _textlabel.numberOfLines = 0;
        _textlabel.textAlignment = NSTextAlignmentCenter;
    }
    return _textlabel;
}

-(void)setTextStr:(NSString *)textStr
{
    _textStr = textStr;
    _textlabel.text = textStr;
}


@end
