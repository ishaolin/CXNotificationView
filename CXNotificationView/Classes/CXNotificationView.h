//
//  CXNotificationView.h
//  Pods
//
//  Created by wshaolin on 2018/6/29.
//

#import "CXNotificationType.h"

@interface CXNotificationView : UIView

@property (nonatomic, copy) CXNotificationShouldDisplayBlock shouldDisplayBlock;
@property (nonatomic, copy) CXNotificationWillDisplayBlock willDisplayBlock;
@property (nonatomic, copy) CXNotificationDidDisplayBlock didDisplayBlock;
@property (nonatomic, copy) CXNotificationWillCloseBlock willCloseBlock;
@property (nonatomic, copy) CXNotificationDidCloseBlock didCloseBlock;

@property (nonatomic, assign, readonly) BOOL isAnimating;
@property (nonatomic, strong, readonly) UIImageView *backgroundView;
@property (nonatomic, assign, readonly) CXNotificationViewCloseType closeType;
@property (nonatomic, strong, readonly) UIView *contentView;

@property (nonatomic, copy) NSString *identifier;

- (instancetype)initWithContentView:(UIView *)contentView
                           duration:(NSTimeInterval)duration
                    notificationTag:(NSInteger)notificationTag
                  simpleActionBlock:(CXNotificationSimpleActionBlock)simpleActionBlock;

+ (CXNotificationView *)viewWithIcon:(UIImage *)icon
                               title:(NSString *)title
                                text:(NSString *)text
                            duration:(NSTimeInterval)duration
                   simpleActionBlock:(CXNotificationSimpleActionBlock)simpleActionBlock;

+ (CXNotificationView *)viewWithContentView:(UIView *)contentView
                                   duration:(NSTimeInterval)duration
                            notificationTag:(NSInteger)notificationTag
                                 identifier:(NSString*)identifier
                         shouldDisplayBlock:(CXNotificationShouldDisplayBlock)shouldDisplayBlock
                           willDisplayBlock:(CXNotificationWillDisplayBlock)willDisplayBlock
                          simpleActionBlock:(CXNotificationSimpleActionBlock)simpleActionBlock;

+ (CXNotificationView *)viewWithContentView:(UIView *)contentView
                                   duration:(NSTimeInterval)duration
                            notificationTag:(NSInteger)notificationTag
                          simpleActionBlock:(CXNotificationSimpleActionBlock)simpleActionBlock;

// 加入到显示队列中
- (void)addToNotificationDisplayQueue;

- (void)dismiss;

+ (void)dismissWithTag:(NSInteger)tag;

+ (void)dismissWithIdentifier:(NSString*)identifier;

@end

CX_FOUNDATION_EXTERN CXNotificationName const CXNotificationViewTouchActionNotification;
