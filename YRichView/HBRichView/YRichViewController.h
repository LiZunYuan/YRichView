//
//  HBRichViewController.h
//  MGJIndex
//
//  Created by 李遵源 on 16/3/16.
//  Copyright © 2016年 李遵源. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YRichView.h"

@interface YRichViewController : UIViewController<YRichViewDataSource,YRichViewDelegate>
@property (nonatomic, strong) YRichView *richView;
@end
