//
//  XCCircleScrollView.h
//  demo
//
//  Created by luds on 16/3/30.
//  Copyright © 2016年 luds. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface XCCircleScrollView : UIView

/**
 *  快速实例化
 *
 *  @param frame        frame
 *  @param images       需要展示的所有的图片
 *  @param shouldCircle 是否需要循环滚动
 *  @param clickAtIndex 点击了某个图片的回调
 *
 *  @return scrollView
 */
+ (instancetype)scrollViewWithFrame:(CGRect)frame
                             images:(NSArray *)images
                       shouldCircle:(BOOL)shouldCircle
                      clickCallBack:(void (^) (NSInteger index))clickAtIndex;

@end
