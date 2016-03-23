//
//  HBRichDefaultLoadingScrollView.m
//  MGJIndex
//
//  Created by 李遵源 on 16/3/23.
//  Copyright © 2016年 李遵源. All rights reserved.
//

#import "YRichDefaultLoadingScrollView.h"

@interface YRichDefaultLoadingScrollView()
@property (nonatomic, strong) UIActivityIndicatorView* activityIndicatorView;;


@end
@implementation YRichDefaultLoadingScrollView
{
    
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        _activityIndicatorView = [[UIActivityIndicatorView alloc] init];
        [_activityIndicatorView setActivityIndicatorViewStyle:UIActivityIndicatorViewStyleGray];
        [self addSubview:_activityIndicatorView];
        [self setBackgroundColor:[UIColor whiteColor]];
    }
    return self;
}

-(void)layoutSubviews
{
    [super layoutSubviews];
    [_activityIndicatorView setCenter:CGPointMake(self.frame.size.width/2.0, 20)];
    [_activityIndicatorView startAnimating];
}



@end
