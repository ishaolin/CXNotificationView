//
//  CXNotificationDefaultContentView.m
//  Pods
//
//  Created by wshaolin on 2018/6/29.
//

#import "CXNotificationDefaultContentView.h"
#import <CXUIKit/CXUIKit.h>

@interface CXNotificationDefaultContentView () {
    UIImageView *_iconView;
    UILabel *_titleLabel;
    UILabel *_textLabel;
}

@end

@implementation CXNotificationDefaultContentView

- (instancetype)initWithIcon:(UIImage *)icon title:(NSString *)title text:(NSString *)text{
    if(self = [super initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width - 20.0, 75.0)]){
        self.backgroundColor = CXHexIColor(0xC9D4DE);
        
        _iconView = [[UIImageView alloc] init];
        _iconView.image = icon;
        
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.font = CX_PingFangSC_RegularFont(13.0);
        _titleLabel.textColor = [CXHexIColor(0x353C43) colorWithAlphaComponent:0.7];
        _titleLabel.text = title;
        
        _textLabel = [[UILabel alloc] init];
        _textLabel.font = CX_PingFangSC_RegularFont(14.0);
        _textLabel.textColor = CXHexIColor(0x353C43);
        _textLabel.text = text;
        
        [self addSubview:_iconView];
        [self addSubview:_titleLabel];
        [self addSubview:_textLabel];
    }
    
    return self;
}

- (void)layoutSubviews{
    [super layoutSubviews];
    
    CGFloat iconView_W = 24.0;
    CGFloat iconView_H = iconView_W;
    CGFloat iconView_X = 13.0;
    CGFloat iconView_Y = iconView_X;
    _iconView.frame = (CGRect){iconView_X, iconView_Y, iconView_W, iconView_H};
    
    CGFloat titleLabel_X = CGRectGetMaxX(_iconView.frame) + 7.0;
    CGFloat titleLabel_W = CGRectGetWidth(self.bounds) - titleLabel_X - iconView_X;
    CGFloat titleLabel_H = iconView_H;
    CGFloat titleLabel_Y = iconView_Y;
    _titleLabel.frame = (CGRect){titleLabel_X, titleLabel_Y, titleLabel_W, titleLabel_H};
    
    CGFloat textLabel_X = iconView_X;
    CGFloat textLabel_W = CGRectGetWidth(self.bounds) - textLabel_X * 2;
    CGFloat textLabel_H = 28.0;
    CGFloat textLabel_Y = CGRectGetMaxY(_iconView.frame);
    _textLabel.frame = (CGRect){textLabel_X, textLabel_Y, textLabel_W, textLabel_H};
    
    [self cx_roundedCornerRadii:4.0];
}

@end
