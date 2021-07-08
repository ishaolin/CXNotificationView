//
//  CXNotificationView.m
//  Pods
//
//  Created by wshaolin on 2018/6/29.
//

#import "CXNotificationView.h"
#import "CXNotificationWindow.h"
#import "CXNotificationDefaultContentView.h"
#import <CXUIKit/CXUIKit.h>

@interface CXNotificationView () {
    CGPoint _touchPoint;
    BOOL _draged;
    NSTimeInterval _duration;
}

@property (nonatomic, copy) CXNotificationSimpleActionBlock simpleActionBlock;

@end

@implementation CXNotificationView

- (instancetype)initWithContentView:(UIView *)contentView
                           duration:(NSTimeInterval)duration
                    notificationTag:(NSInteger)notificationTag
                  simpleActionBlock:(CXNotificationSimpleActionBlock)simpleActionBlock{
    CGFloat offset = [UIScreen mainScreen].cx_isBangs ? 50.0 : 30.0;
    CGFloat x = 0;
    CGFloat y = 0;
    CGFloat width = CGRectGetWidth(contentView.frame);
    CGFloat height = CGRectGetHeight(contentView.frame) + offset + 20.0;
    
    CGRect contentFrame = contentView.frame;
    contentFrame.origin.y = offset;
    contentView.frame = contentFrame;
    
    if(self = [super initWithFrame:CGRectMake(x, y, width, height)]){
        self.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        self.simpleActionBlock = simpleActionBlock;
        self.tag = notificationTag;
        _duration = MAX(duration, 1.0);
        
        _backgroundView = [[UIImageView alloc] initWithFrame:self.contentView.frame];
        [self addSubview:_backgroundView];
        
        _contentView = contentView;
        [self addSubview:contentView];
        
        _contentView.userInteractionEnabled = YES;
        [_contentView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapGestureRecognizer:)]];
    }
    
    return self;
}

- (void)dismiss{
    if(self == [CXNotificationWindow sharedWindow].currentView){
        _closeType = CXNotificationViewCloseTypeExternalDismiss;
        [self.class showNextNotification];
    }else{
        [[CXNotificationWindow sharedWindow] removeNotificationView:self];
    }
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    _touchPoint = [[touches anyObject] locationInView:self.superview];
    
    [NSObject cancelPreviousPerformRequestsWithTarget:[self class] selector:@selector(showNextNotification) object:nil];
    [self cancelPerformDurationTimeoutSelector];
    _draged = YES;
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event{
    CGPoint touchPoint = [[touches anyObject] locationInView:self.superview];
    CGRect frame = self.frame;
    frame.origin.y += touchPoint.y - _touchPoint.y;
    
    if(frame.origin.y > -frame.size.height && frame.origin.y < 0) {
        _touchPoint = touchPoint;
        _draged = YES;
        self.frame = frame;
    }
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{
    CXNotificationView *notificationView = [CXNotificationWindow sharedWindow].currentView;
    if(!notificationView->_draged || notificationView.isAnimating){
        return;
    }
    
    if(notificationView){
        notificationView->_closeType = CXNotificationViewCloseTypeUpDraged;
    }
    
    if(self.frame.origin.y > -self.frame.size.height * 0.1){
        [self.class performSelector:@selector(showNextNotification) withObject:nil afterDelay:2.0];
    }else{
        [self.class showNextNotification];
    }
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event{
    CXNotificationView *notificationView = [CXNotificationWindow sharedWindow].currentView;
    
    if(self.frame.origin.y > -self.frame.size.height * 0.1){
        if(self == notificationView){
            [notificationView performSelector:@selector(durationTimeout) withObject:nil afterDelay:2.0];
        }
    }else{
        if(notificationView){
            notificationView->_closeType = CXNotificationViewCloseTypeUpDraged;
        }
        
        [self.class showNextNotification];
    }
}

+ (void)showNextNotification{
    [NSObject cancelPreviousPerformRequestsWithTarget:[CXNotificationWindow sharedWindow].currentView selector:@selector(durationTimeout) object:nil];
    
    [NSObject cancelPreviousPerformRequestsWithTarget:[self class] selector:@selector(showNextNotification) object:nil];
    
    CXNotificationView *outNotificationView = [CXNotificationWindow sharedWindow].currentView;
    CXNotificationView *inNotificationView = [[CXNotificationWindow sharedWindow] notificationViewFromQueue];
    if(inNotificationView){
        [CXNotificationWindow sharedWindow].hidden = NO;
        
        BOOL shouldDisplay = YES;
        if(inNotificationView.shouldDisplayBlock){
            shouldDisplay = inNotificationView.shouldDisplayBlock(inNotificationView);
        }
        
        if(!shouldDisplay){
            [[CXNotificationWindow sharedWindow] removeNotificationView:inNotificationView];
            [self.class showNextNotification];
            return;
        }
    }
    
    [[CXNotificationWindow sharedWindow] updateCurrentNotificationView:nil];
    [self handleNotificationViewOut:outNotificationView showIn:inNotificationView];
}

- (void)layoutSubviews{
    [super layoutSubviews];
    
    _backgroundView.frame = _contentView.frame;
}

- (void)durationTimeout{
    _closeType = CXNotificationViewCloseTypeDurationDeplete;
    [self.class showNextNotification];
}

- (void)handleTapGestureRecognizer:(UITapGestureRecognizer *)tapGestureRecognizer{
    if(self.simpleActionBlock){
        self.simpleActionBlock(self);
    }
    
    [NSNotificationCenter notify:CXNotificationViewTouchActionNotification];
    
    if(!_isAnimating){
        _closeType = CXNotificationViewCloseTypeClickedSelf;
        [self.class showNextNotification];
    }
}

+ (void)dismissWithTag:(NSInteger)tag{
    [[CXNotificationWindow sharedWindow] dismissNotificationWithTag:tag];
}

+ (void)dismissWithIdentifier:(NSString *)identifier{
    [[CXNotificationWindow sharedWindow] dismissNotificationWithIdentifier:identifier];
}

+ (void)handleNotificationViewOut:(CXNotificationView *)outView showIn:(CXNotificationView *)inView{
    if(!outView){
        [inView showIn];
        return;
    }
    
    if(outView.willCloseBlock){
        outView.willCloseBlock(outView);
    }
    
    outView->_isAnimating = YES;
    CGRect frame = outView.frame;
    frame.origin.y = -CGRectGetHeight(frame);
    [UIView animateWithDuration:0.4 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        outView.frame = frame;
    } completion:^(BOOL finished) {
        outView->_isAnimating = NO;
        if(outView.didCloseBlock){
            outView.didCloseBlock(outView);
        }
        
        [outView removeFromSuperview];
        [[CXNotificationWindow sharedWindow] removeNotificationView:outView];
        
        if(!inView){
            [CXNotificationWindow sharedWindow].hidden = YES;
        }
        
        [inView showIn];
    }];
}

- (void)showIn{
    CGSize size = self.frame.size;
    self.frame = (CGRect){(CGRectGetWidth([CXNotificationWindow sharedWindow].bounds) - size.width) * 0.5, -size.height, size};
    if(self.willDisplayBlock){
        self.willDisplayBlock(self);
    }
    
    [[CXNotificationWindow sharedWindow] addSubview:self];
    [CXNotificationWindow sharedWindow].hidden = NO;
    [[CXNotificationWindow sharedWindow] updateCurrentNotificationView:self];
    _isAnimating = YES;
    
    [UIView animateWithDuration:0.4 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        self.frame = (CGRect){self.frame.origin.x, 0, size};
    } completion:^(BOOL finished) {
        self->_isAnimating = NO;
        [self performSelector:@selector(durationTimeout) withObject:nil afterDelay:self->_duration];
        
        [[CXNotificationWindow sharedWindow] removeNotificationView:self];
        if(self.didDisplayBlock){
            self.didDisplayBlock(self);
        }
    }];
}

+ (CXNotificationView *)viewWithIcon:(UIImage *)icon
                               title:(NSString *)title
                                text:(NSString *)text
                            duration:(NSTimeInterval)duration
                   simpleActionBlock:(CXNotificationSimpleActionBlock)simpleActionBlock{
    CXNotificationDefaultContentView *contentView = [[CXNotificationDefaultContentView alloc] initWithIcon:icon title:title text:text];
    return [CXNotificationView viewWithContentView:contentView
                                          duration:duration
                                   notificationTag:0
                                 simpleActionBlock:simpleActionBlock];
}

+ (CXNotificationView *)viewWithContentView:(UIView *)contentView
                                   duration:(NSTimeInterval)duration
                            notificationTag:(NSInteger)notificationTag
                          simpleActionBlock:(CXNotificationSimpleActionBlock)simpleActionBlock{
    return [self viewWithContentView:contentView
                            duration:duration
                     notificationTag:notificationTag
                          identifier:nil
                  shouldDisplayBlock:nil
                    willDisplayBlock:nil
                   simpleActionBlock:simpleActionBlock];
}

+ (CXNotificationView *)viewWithContentView:(UIView *)contentView
                                   duration:(NSTimeInterval)duration
                            notificationTag:(NSInteger)notificationTag
                                 identifier:(NSString *)identifier
                         shouldDisplayBlock:(CXNotificationShouldDisplayBlock)shouldDisplayBlock
                           willDisplayBlock:(CXNotificationWillDisplayBlock)willDisplayBlock
                          simpleActionBlock:(CXNotificationSimpleActionBlock)simpleActionBlock{
    CXNotificationView *notificationView = [[CXNotificationView alloc] initWithContentView:contentView duration:duration notificationTag:notificationTag simpleActionBlock:simpleActionBlock];
    notificationView.shouldDisplayBlock  = shouldDisplayBlock;
    notificationView.willDisplayBlock    = willDisplayBlock;
    notificationView.identifier          = identifier;
    return notificationView;
}

- (void)addToNotificationDisplayQueue{
    [[CXNotificationWindow sharedWindow] addNotificationView:self];
    if([CXNotificationWindow sharedWindow].currentView || [CXNotificationWindow sharedWindow].animatingView){
        return;
    }
    
    [self.class showNextNotification];
}

- (void)cancelPerformDurationTimeoutSelector{
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(durationTimeout) object:nil];
}

- (void)removeFromSuperview{
    [super removeFromSuperview];
    [self cancelPerformDurationTimeoutSelector];
}

- (void)dealloc{
    [self cancelPerformDurationTimeoutSelector];
}

@end

CXNotificationName const CXNotificationViewTouchActionNotification = @"_NotificationViewTouchActionNotification";
