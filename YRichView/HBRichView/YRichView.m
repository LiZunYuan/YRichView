//
//  HBRichView.m
//  MGJIndex
//
//  Created by 李遵源 on 16/3/17.
//  Copyright © 2016年 李遵源. All rights reserved.
//

#import "YRichView.h"
#import "YRichDefaultLoadingScrollView.h"
//#import "YZRichDefalutLoadingScroll"

@interface YRichView()<UIScrollViewDelegate>
@property (nonatomic, strong) UIScrollView *contentScrollView;
@property (nonatomic, strong) UIView *headerView;//头视图
@property (nonatomic, strong) UIView *topView;//顶部视图
@property (nonatomic, strong) UIView *middleView;//中间突出的视图
@property (nonatomic, assign) CGFloat headerViewHeight;
@property (nonatomic, assign) CGFloat middleViewHeight;
@property (nonatomic, assign) NSInteger countOfScrollViews;

@property (nonatomic, strong) NSMutableSet *loadIndexSet;//加载的索引集合
@property (nonatomic, strong) NSMutableArray<UIScrollView *> *tableviewArray;//tableview数组
@property (nonatomic, strong) UIScrollView *currentScrollView;
@property (nonatomic, assign) BOOL needChangeTableViewOffsetY;// 判断是否需要更新tableview的offset  防止遗失用户的轨迹
@end


@implementation YRichView

- (instancetype)init
{
    self = [super init];
    if (self) {
        _topView = [[UIView alloc] init];
        _loadIndexSet = [NSMutableSet set];
        
        _contentScrollView = [[UIScrollView alloc] init];
        _contentScrollView.delegate = self;
        _contentScrollView.bounces = NO;
        _contentScrollView.showsHorizontalScrollIndicator = NO;
        _contentScrollView.pagingEnabled = YES;
    }
    return self;
}

- (void)reloadData
{
    self.headerViewHeight = [self __headerViewHeight];
    self.middleViewHeight = [self __middleViewHeight];
    
    self.headerView = [self __headerView];
    [_headerView setFrame:CGRectMake(0, 0, self.frame.size.width, [self __headerViewHeight])];
    
    self.middleView = [self __middleView];
    [_middleView setFrame:CGRectMake(0, [self headerViewHeight], self.frame.size.width, [self __middleViewHeight])];
    
    self.countOfScrollViews = [self __countOfScrollViews];
    
    [self.topView setFrame:CGRectMake(self.topView.frame.origin.x, self.topView.frame.origin.y, self.topView.frame.size.width, self.headerViewHeight + self.middleViewHeight)];
    if (self.headerView) {
        [self.topView addSubview:self.headerView];
    }
    if (self.middleView) {
        [self.topView addSubview:self.middleView];
    }
    
    [self.contentScrollView setContentSize:CGSizeMake([UIScreen mainScreen].bounds.size.width*self.countOfScrollViews, [UIScreen mainScreen].bounds.size.height)];
    [self addSubview:self.contentScrollView];
    
    [_loadIndexSet removeAllObjects];
    
    
    [self.contentScrollView setFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
    [self.topView setFrame:CGRectMake(0, 0, self.frame.size.width, _topView.frame.size.height)];
    
    NSMutableArray *scrollViewArray = [NSMutableArray array];
    for (NSUInteger i = 0; i < self.countOfScrollViews; i++) {
        UIScrollView *loadingScrollView = [self __loadingScrollViewAtIndex:i];
        [_contentScrollView addSubview:loadingScrollView];
        [self initializeScrollView:loadingScrollView withIndex:i];
        [loadingScrollView setContentSize:CGSizeMake(self.frame.size.width, self.frame.size.height)];
        [loadingScrollView setContentOffset:CGPointMake(0, -(self.headerViewHeight + self.middleViewHeight))];
        [scrollViewArray addObject:loadingScrollView];
    }
    
    _tableviewArray = scrollViewArray;
    
    [self goIndex:0];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [self reloadData];
    });
    
}

- (UIScrollView *)initializeScrollView:(UIScrollView *)scrollView withIndex:(NSInteger)i
{
    [scrollView setFrame:CGRectMake(i * [UIScreen mainScreen].bounds.size.width, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height)];
    [scrollView setContentInset:UIEdgeInsetsMake(self.headerViewHeight + self.middleViewHeight, 0, 0, 0)];
    [scrollView addObserver:self forKeyPath:NSStringFromSelector(@selector(contentOffset)) options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld context:nil];
    return scrollView;
}

- (void)showScrollViewWithIndex:(NSInteger)index
{
    UIScrollView *targetScrollView = _tableviewArray[index];
    [self scrollViewWillBeginDragging:_contentScrollView];
    [_contentScrollView setContentOffset:CGPointMake(targetScrollView.frame.origin.x, 0) animated:NO];
    [self scrollViewDidEndDecelerating:_contentScrollView];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self goIndex:index];
    });
}

- (void)goIndex:(NSUInteger)index
{
    UIScrollView *goScrollView;
    if ([self.loadIndexSet containsObject:@(index)]) {
        goScrollView = self.tableviewArray[index];
    }else {
        goScrollView = [self.dataSource richView:self scrollViewForIndex:index];
        UIScrollView *loadingView = [self.tableviewArray objectAtIndex:index];
        [loadingView removeObserver:self forKeyPath:NSStringFromSelector(@selector(contentOffset))];
        [loadingView removeFromSuperview];
        [self.tableviewArray replaceObjectAtIndex:index withObject:goScrollView];
        CGPoint loadingViewContentOffset = loadingView.contentOffset;
        [_contentScrollView addSubview:goScrollView];
        [self initializeScrollView:goScrollView withIndex:index];
        [goScrollView setContentOffset:loadingViewContentOffset];
        [self.loadIndexSet addObject:@(index)];
    }
    
    [goScrollView addSubview:_topView];
    if (goScrollView.contentOffset.y < -[self middleViewHeight]) {
        [_topView setFrame:CGRectMake(0, -(_headerView.frame.size.height + _middleView.frame.size.height), _headerView.frame.size.width, _topView.frame.size.height)];
    } else {
        [_topView setFrame:CGRectMake(0,  goScrollView.contentOffset.y - _headerView.frame.size.height, _headerView.frame.size.width, _topView.frame.size.height)];
    }
    
    [_contentScrollView bringSubviewToFront:goScrollView];
    _currentScrollView = goScrollView;
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(UIScrollView *)targetScrollView change:(NSDictionary<NSString *,id> *)change context:(void *)context
{
    if (targetScrollView == _currentScrollView && [keyPath isEqualToString:@"contentOffset"]) {
        CGFloat contentOffsetY = targetScrollView.contentOffset.y;
        CGFloat headerViewY;
        if(contentOffsetY < -[self middleViewHeight]){
            headerViewY = 0;
        }else {
            headerViewY = contentOffsetY + [self middleViewHeight];
        }
        [_topView setFrame:CGRectMake(_headerView.frame.origin.x, headerViewY-([self headerViewHeight] + [self middleViewHeight]), _topView.frame.size.width, _topView.frame.size.height)];
        
        CGPoint oldValue = [change[NSKeyValueChangeOldKey] CGPointValue];
        CGPoint newValue = [change[NSKeyValueChangeNewKey] CGPointValue];
        if(newValue.y < oldValue.y ) {
            _needChangeTableViewOffsetY = YES;
        }
    }
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    NSInteger index = scrollView.contentOffset.x / _contentScrollView.frame.size.width;
    UIScrollView *currentTableView = _tableviewArray[index];
    if (_topView.frame.origin.y == -([self headerViewHeight] + [self middleViewHeight])){
        //如果当前的contentOffset比其它的大，强制设置
        if (_needChangeTableViewOffsetY == NO) {
            for (UITableView *tableview in _tableviewArray) {
                if( _currentScrollView == tableview){
                    continue;
                }
                if(_currentScrollView.contentOffset.y > tableview.contentOffset.y) {
                    _needChangeTableViewOffsetY = YES;
                }
            }
        }
        //这里需要把其它都置成0
        if(_needChangeTableViewOffsetY){
            for (UIScrollView *scrollView in _tableviewArray) {
                if(scrollView == currentTableView){
                    continue;
                }
                [scrollView setContentOffset:CGPointMake(0, _currentScrollView.contentOffset.y) animated:NO];
            }
            _needChangeTableViewOffsetY = NO;
        }
    } else {
        for (UITableView *tableview in _tableviewArray) {
            if (tableview == currentTableView){
                continue;
            }
            if (tableview.contentOffset.y < -[self middleViewHeight]) {
                
                [tableview setContentOffset:CGPointMake(0, -[self middleViewHeight]) animated:NO];
            }
        }
    }
    for (UITableView *tableview in _tableviewArray) {
        [tableview setClipsToBounds:NO];
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    CGFloat contentOffsetX = scrollView.contentOffset.x;
    [_topView setFrame:CGRectMake((contentOffsetX-_currentScrollView.frame.origin.x), _topView.frame.origin.y, _topView.frame.size.width, _topView.frame.size.height)];
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    NSInteger index = scrollView.contentOffset.x / _contentScrollView.frame.size.width;
    [self goIndex:index];
    
    for (UITableView *tableview in _tableviewArray) {
        [tableview setClipsToBounds:YES];
    }
}

/////通过代理拿的数据
- (NSInteger)__countOfScrollViews
{
    if ([self.dataSource respondsToSelector:@selector(countOfScrollViewsInRichView:)]) {
        return [self.dataSource countOfScrollViewsInRichView:self];
    }
    return 1;
}

- (UIView *)__headerView
{
    if ([self.delegate respondsToSelector:@selector(headerViewInRichView:)]) {
        return [self.delegate headerViewInRichView:self];
    }
    return nil;
}

- (CGFloat)__headerViewHeight
{
    
    if([self.delegate respondsToSelector:@selector(heightForHeaderViewInRichView:)]) {
        return [self.delegate heightForHeaderViewInRichView:self];
    }
    return 0;
}

- (UIView *)__middleView
{
    if ([self.delegate respondsToSelector:@selector(middleViewInRichView:)]) {
        return [self.delegate middleViewInRichView:self];
    }
    return nil;
}

- (CGFloat)__middleViewHeight
{
    
    if([self.delegate respondsToSelector:@selector(heightForMiddleViewInRichView:)]) {
        return [self.delegate heightForMiddleViewInRichView:self];
    }
    return 0;
}

- (UIScrollView *)__loadingScrollViewAtIndex:(NSInteger)index
{
    UIScrollView *loadingScrollView;
    if ([self.dataSource respondsToSelector:@selector(richView:loadingScrollViewForIndex:)]) {
        loadingScrollView = [self.dataSource richView:self loadingScrollViewForIndex:index];
    }
    
    if (loadingScrollView == nil) {
        loadingScrollView = [[YRichDefaultLoadingScrollView alloc] init];
    }
    return loadingScrollView;
}

- (void)dealloc
{
    [self.tableviewArray enumerateObjectsUsingBlock:^(UIScrollView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [obj removeObserver:self forKeyPath:NSStringFromSelector(@selector(contentOffset))];
    }];
}
@end
