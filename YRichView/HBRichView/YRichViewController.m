//
//  HBRichViewController.m
//  MGJIndex
//
//  Created by 李遵源 on 16/3/16.
//  Copyright © 2016年 李遵源. All rights reserved.
//

#import "YRichViewController.h"

@interface YRichViewController ()
@end

@implementation YRichViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.richView setFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height)];
    self.richView.delegate = self;
    self.richView.dataSource = self;
}

- (NSUInteger)countOfRichView
{
    return 0;
}

- (void)loadView
{
    self.richView = [[YRichView alloc] init];
    self.view = self.richView;
}

-(UIScrollView *)richView:(YRichView *)richView scrollViewForIndex:(NSInteger)index
{
    return [[UIScrollView alloc] init];
}

@end
