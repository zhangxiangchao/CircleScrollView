//
//  XCCircleScrollView.m
//  demo
//
//  Created by luds on 16/3/30.
//  Copyright © 2016年 luds. All rights reserved.
//

#import "XCCircleScrollView.h"

@interface UIImageView (loadImage)

- (void)xc_setImageWithURL:(NSString *)URL
               shoudlCache:(BOOL)shouldCache;

@end

@interface NSString (MD5)

- (NSString *)MD5String;

@end



@interface XCCircleScrollView ()<UIScrollViewDelegate>


@property (nonatomic, strong) NSArray       *images;        // 所有要显示的图片
@property (nonatomic, assign) BOOL          shouldCircle;   // 是否需要循环滚动

@property (nonatomic, strong) UIScrollView  *scrollView;    // 显示scrollView

@end

@implementation XCCircleScrollView


+ (instancetype)scrollViewWithFrame:(CGRect)frame images:(NSArray *)images shouldCircle:(BOOL)shouldCircle clickCallBack:(void (^)(NSInteger))clickAtIndex {
    // 实例化一个scrollView
    XCCircleScrollView *xc_scrollView = [[XCCircleScrollView alloc] initWithFrame:frame];
    // 设置是否循环滚动
    xc_scrollView.shouldCircle = shouldCircle;
    // 设置所有图片
    xc_scrollView.images = images;
    // 返回scrollView
    return xc_scrollView;
}

// 设置所有要显示的图片
- (void)setImages:(NSArray *)images {
    _images = images;
    // 先移除原来的所有的图片
    [self clearOriginalImages];
    // 添加新的图片
    [self addNewImages];
}

// 添加新的图片
- (void)addNewImages {
    
    float width = self.frame.size.width;
    float height = self.frame.size.height;
    
    // 获取真正需要显示的图片的数量
    NSInteger totalCount = self.shouldCircle ? _images.count + 2 : _images.count;
    
    
    // 添加新的图片
    for (int index = 0; index < totalCount; index++) {
        
        NSString *image ;
        
        if (self.shouldCircle) {
            if (index == 0) {
                image = _images.lastObject;
            }
            else if (index == _images.count + 1) {
                image = _images.firstObject;
            }
            else {
                image = _images[index - 1];
            }
        }
        else {
            image = _images[index];
        }
        
        // 实例化imageView
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(width * index, 0, width, height)];
        // 根据不同的类型, 设置不同的图片
        [self imageView:imageView loadImage:image];
        
        [self.scrollView addSubview:imageView];
        [self.scrollView setContentSize:CGSizeMake(CGRectGetMaxX(imageView.frame), 0)];
    }
    // 设置最初显示页
    self.scrollView.contentOffset = self.shouldCircle ? CGPointMake(CGRectGetWidth(self.scrollView.frame), 0) : CGPointZero;
}

// 给某一个imageView添加图片
- (void)imageView:(UIImageView *)imageView loadImage:(NSString *)image {
    if ([image hasPrefix:@"http://"] || [image hasPrefix:@"https://"]) {
        [imageView xc_setImageWithURL:image shoudlCache:YES];
    }
    else {
        imageView.image = [UIImage imageNamed:image];
    }
}

/**
 *  清除原来scrollView上面所有的图片
 */
- (void)clearOriginalImages {
    for (UIView *subView in self.scrollView.subviews) {
        [subView removeFromSuperview];
    }
}


#pragma mark ------------- 循环滚动实现 -------------
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    if (!self.shouldCircle) return;
    [self circleAction];
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView {
    if (!self.shouldCircle) return;
    [self circleAction];
}
// 循环滚动操作
- (void)circleAction {
    // 1. 获取当前在第几页
    NSInteger page = self.scrollView.contentOffset.x / self.scrollView.frame.size.width;
    // 2. 根据页码处理
    if (page == 0) {
        [self.scrollView setContentOffset:CGPointMake(CGRectGetWidth(self.scrollView.frame) * self.images.count, 0) animated:NO];
    }
    else if (page == self.images.count + 1) {
        [self.scrollView setContentOffset:CGPointMake(CGRectGetWidth(self.scrollView.frame), 0) animated:NO];
    }
}

#pragma mark ------------- 视图懒加载 ---------------
- (UIScrollView *)scrollView {
    if (_scrollView == nil) {
        _scrollView = [[UIScrollView alloc] initWithFrame:self.bounds];
        _scrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        _scrollView.delegate = self;
        _scrollView.pagingEnabled = YES;
        _scrollView.showsHorizontalScrollIndicator = NO;
        _scrollView.showsVerticalScrollIndicator = NO;
        [self addSubview:_scrollView];
    }
    return _scrollView;
}

@end





#pragma mark --------------- UIImageView类别 -------------

@implementation UIImageView (loadImage)
/**
 *  加载一张网络图片
 *
 *  @param URL         图片地址
 *  @param shouldCache 是否需要缓存
 */
- (void)xc_setImageWithURL:(NSString *)URL shoudlCache:(BOOL)shouldCache {
    
    // 先读取本地的图片
    NSData *localData = nil;
    if ((localData = [self fileFromPath:URL])) {
        self.image = [UIImage imageWithData:localData];
    }
    else {
        // 异步加载一张网络图片
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:URL]];
            [self cache:data withName:URL];
            dispatch_async(dispatch_get_main_queue(), ^{
                self.image = [UIImage imageWithData:data];
            });
        });
    }
}

// 缓存一张图片到本地
- (void)cache:(NSData *)data withName:(NSString *)fileName {
    // 获取路径
    NSString *path = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).firstObject stringByAppendingString:[NSString stringWithFormat:@"/%@", fileName.MD5String]];
    // 保存到本地
    [data writeToFile:path atomically:YES];
}

// 读取本地的图片
- (NSData *)fileFromPath:(NSString *)fileName {
    // 拼接路径
    NSString *path = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).firstObject stringByAppendingString:[NSString stringWithFormat:@"/%@", fileName.MD5String]];
    // 从本地读取, 并返回
    return [NSData dataWithContentsOfFile:path];
}


@end

#import <CommonCrypto/CommonDigest.h>
@implementation NSString (MD5)

- (NSString *)MD5String {
    const char *original_str = [self UTF8String];
    unsigned char result[CC_MD5_DIGEST_LENGTH];
    CC_MD5(original_str, (int)strlen(original_str), result);
    NSMutableString *hash = [NSMutableString string];
    for (int i = 0; i < 16; i++)
        [hash appendFormat:@"%02X", result[i]];
    return [hash lowercaseString];
}

@end










