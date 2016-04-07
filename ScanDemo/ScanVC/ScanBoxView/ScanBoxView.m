//
//  ScanBoxView.m
//  ScanDemo
//
//  Created by 韩威 on 16/4/7.
//  Copyright © 2016年 韩威. All rights reserved.
//

#import "ScanBoxView.h"

static NSTimeInterval const duration = 2.5;

@interface ScanBoxView ()

@property (nonatomic, strong) UIImageView *boxBgImgView;
@property (nonatomic, strong) UIImageView *scanLineImgView;

@property (nonatomic, strong) dispatch_source_t timer;

@end

@implementation ScanBoxView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setup];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self setup];
    }
    return self;
}

- (void)setup {
    UIImage *boxBgImg = [UIImage imageNamed:@"scanBoxBg"];
    self.boxBgImgView = [[UIImageView alloc] initWithImage:boxBgImg];
    
    UIImage *scanLineImg = [UIImage imageNamed:@"scanLine"];
    self.scanLineImgView = [[UIImageView alloc] initWithImage:scanLineImg];
    
    [self addSubview:self.boxBgImgView];
    [self addSubview:self.scanLineImgView];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.boxBgImgView.frame = self.bounds;
    self.scanLineImgView.frame = CGRectMake(0, 0, self.bounds.size.width, 1.0f);
}

#pragma mark - public
- (void)startScanAnimation {
    _timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, dispatch_get_main_queue());
    dispatch_source_set_timer(_timer, DISPATCH_TIME_NOW, duration * NSEC_PER_SEC, 0 * NSEC_PER_SEC);
    dispatch_source_set_event_handler(_timer, ^{
        self.scanLineImgView.frame = CGRectMake(0, 0, self.bounds.size.width, 1.0f);
        CGRect frame = self.scanLineImgView.frame;
        frame.origin.y = self.bounds.size.height;
        
        [UIView animateWithDuration:duration
                              delay:0
                            options:UIViewAnimationOptionCurveLinear
                         animations:^{
                             self.scanLineImgView.frame = frame;
                         }
                         completion:^(BOOL finished) {
                             
                         }];
    });
    dispatch_resume(_timer);
}

- (void)stopScanAnimation {
    //暂时挂起
    //dispatch_suspend(_timer);
    //如果取消的话，再调用`dispatch_resume(self.timer);`这句代码就会Crash。要想不崩溃就得重新创建`_timer`.
    dispatch_source_cancel(_timer);
    self.scanLineImgView.frame = CGRectMake(0, 0, self.bounds.size.width, 1.0f);
}

#pragma mark - getter
//- (dispatch_source_t)timer {
//    if (!_timer) {
//        _timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, dispatch_get_main_queue());
//        dispatch_source_set_timer(_timer, DISPATCH_TIME_NOW, duration * NSEC_PER_SEC, 0 * NSEC_PER_SEC);
//    }
//    return _timer;
//}

@end

