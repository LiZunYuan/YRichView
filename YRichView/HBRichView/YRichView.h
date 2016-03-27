//
//  HBRichView.h
//  MGJIndex
//
//  Created by 李遵源 on 16/3/17.
//  Copyright © 2016年 李遵源. All rights reserved.
//

#import <UIKit/UIKit.h>
@class YRichView;

@protocol YRichViewDataSource<NSObject>
- (UIScrollView *)richView:(YRichView *)richView scrollViewForIndex:(NSInteger)index; //获取第几个scrollview
@optional
- (NSInteger)countOfScrollViewsInRichView:(YRichView *)richView;              // 如果没实现，默认为1
- (UIScrollView *)richView:(YRichView *)richView loadingScrollViewForIndex:(NSInteger)index;//没实现，默认使用HBRichDefaultLoadingScrollView
@end

@protocol YRichViewDelegate<NSObject>
@optional
- (UIView *)headerViewInRichView:(YRichView *)richView;   //header view
- (CGFloat)heightForHeaderViewInRichView:(YRichView *)richView;  //header的高度

- (UIView *)middleViewInRichView:(YRichView *)richView;  //中间需要置顶的 view
- (CGFloat)heightForMiddleViewInRichView:(YRichView *)richView; //置顶view的高度
@end


@interface YRichView : UIView
@property (nonatomic, weak) id<YRichViewDataSource> dataSource;
@property (nonatomic, weak) id<YRichViewDelegate> delegate;
- (void)showScrollViewWithIndex:(NSInteger)index;//滚动到第几个
- (void)reloadData;//刷新数据 未来实现

@end
