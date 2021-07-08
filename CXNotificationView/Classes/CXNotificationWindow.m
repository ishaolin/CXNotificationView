//
//  CXNotificationWindow.m
//  Pods
//
//  Created by wshaolin on 2018/6/29.
//

#import "CXNotificationWindow.h"
#import "CXNotificationView.h"

#define GLNotificationHeight 125.0
#define GL_RADIANS(x) ((x) * M_PI / 180.0)

static inline CGRect _GLNotificationRect(void){
    CGFloat width = CGRectGetWidth([UIScreen mainScreen].bounds);
    if(UIInterfaceOrientationIsLandscape([[UIApplication sharedApplication] statusBarOrientation])){
        width = CGRectGetHeight([UIScreen mainScreen].bounds);
    }
    
    return CGRectMake(0, 0, width, GLNotificationHeight);
}

@interface CXNotificationWindow () {
    NSTimeInterval _animateDuration;
    NSMutableArray<CXNotificationView *> *_notificationViews;
}

@end

@implementation CXNotificationWindow

+ (CXNotificationWindow *)sharedWindow{
    static CXNotificationWindow *_notificationWindow = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _notificationWindow = [[CXNotificationWindow alloc] initWithFrame:_GLNotificationRect()];
    });
    
    return _notificationWindow;
}

- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]){
        self.windowLevel = UIWindowLevelStatusBar + 1;
        self.backgroundColor = [UIColor clearColor];
        self.hidden = YES;
        
        _animateDuration = [UIApplication sharedApplication].statusBarOrientationAnimationDuration;
        _notificationViews = [NSMutableArray array];
        
        [NSNotificationCenter addObserver:self
                                   action:@selector(applicationWillChangeStatusBarFrameNotification:)
                                     name:UIApplicationWillChangeStatusBarFrameNotification];
        
        [self rotateNotificationWindow];
    }
    
    return self;
}

- (void)applicationWillChangeStatusBarFrameNotification:(NSNotification *)notification{
    if(self.hidden){
        [UIView animateWithDuration:_animateDuration animations:^{
            self.alpha = 0;
        } completion:^(BOOL finished) {
            [self rotateNotificationWindow];
            
            [UIView animateWithDuration:self->_animateDuration animations:^{
                self.alpha = 1.0;
            }];
        }];
    }else{
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(_animateDuration * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self rotateNotificationWindow];
        });
    }
}

- (void)rotateNotificationWindow{
    CGRect frame = _GLNotificationRect();
    BOOL portrait = (CGRectGetWidth(frame) == CGRectGetWidth([UIScreen mainScreen].bounds));
    
    if(portrait){
        if([[UIDevice currentDevice] orientation] == UIDeviceOrientationPortraitUpsideDown){
            frame.origin.y = CGRectGetHeight([UIScreen mainScreen].bounds) - GLNotificationHeight;
            self.transform = CGAffineTransformMakeRotation(GL_RADIANS(180.0));
        }else{
            self.transform = CGAffineTransformIdentity;
        }
    }else{
        frame.size = CGSizeMake(GLNotificationHeight, frame.size.width);
        if([[UIDevice currentDevice] orientation] == UIDeviceOrientationLandscapeLeft){
            frame.origin.x = CGRectGetWidth([UIScreen mainScreen].bounds) - CGRectGetWidth(frame);
            self.transform = CGAffineTransformMakeRotation(GL_RADIANS(90.0));
        }else{
            self.transform = CGAffineTransformMakeRotation(GL_RADIANS(-90.0));
        }
    }
    
    self.frame = frame;
    CGPoint center = self.center;
    if(portrait){
        center.x = CGRectGetMidX([UIScreen mainScreen].bounds);
    }else{
        center.y = CGRectGetMidY([UIScreen mainScreen].bounds);
    }
    
    self.center = center;
}

- (CXNotificationView *)animatingNotificationView{
    CXNotificationView *notificationView = [self notificationViewFromQueue];
    return notificationView.isAnimating ? notificationView : nil;
}

- (void)addNotificationView:(CXNotificationView *)notificationView{
    if(notificationView){
        [_notificationViews addObject:notificationView];
    }
}

- (void)removeNotificationView:(CXNotificationView *)notificationView{
    if(notificationView){
        [_notificationViews removeObject:notificationView];
    }
}

- (CXNotificationView *)notificationViewFromQueue{
    return _notificationViews.firstObject;
}

- (void)updateCurrentNotificationView:(CXNotificationView *)notificationView{
    _currentView = notificationView;
    
    if(_currentView){
        CGRect frame = self.frame;
        frame.size.height = CGRectGetHeight(_currentView.frame);
        self.frame = frame;
    }
}

- (void)dismissNotificationWithTag:(NSInteger)tag{
    NSArray<CXNotificationView *> *notificationViews = [NSArray arrayWithArray:_notificationViews];
    [notificationViews enumerateObjectsUsingBlock:^(CXNotificationView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if(obj.tag == tag){
            [obj dismiss];
        }
    }];
    
    if(_currentView.tag == tag){
        [_currentView dismiss];
    }
}

- (void)dismissNotificationWithIdentifier:(NSString *)identifier{
    if(!identifier || identifier.length == 0){
        return;
    }
    
    NSArray<CXNotificationView *> *notificationViews = [NSArray arrayWithArray:_notificationViews];
    [notificationViews enumerateObjectsUsingBlock:^(CXNotificationView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if([obj.identifier isEqualToString:identifier]){
            [obj dismiss];
        }
    }];
    
    if([_currentView.identifier isEqualToString:identifier]){
        [_currentView dismiss];
    }
}

- (void)dealloc{
    [NSNotificationCenter removeObserver:self];
}

@end
