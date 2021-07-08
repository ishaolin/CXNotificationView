//
//  CXNotificationWindow.h
//  Pods
//
//  Created by wshaolin on 2018/6/29.
//

#import <UIKit/UIKit.h>

@class CXNotificationView;

@interface CXNotificationWindow : UIWindow

@property (nonatomic, strong, readonly) CXNotificationView *currentView;
@property (nonatomic, strong, readonly) CXNotificationView *animatingView;

+ (CXNotificationWindow *)sharedWindow;

- (void)addNotificationView:(CXNotificationView *)notificationView;
- (void)removeNotificationView:(CXNotificationView *)notificationView;

- (CXNotificationView *)notificationViewFromQueue;

- (void)updateCurrentNotificationView:(CXNotificationView *)notificationView;

- (void)dismissNotificationWithTag:(NSInteger)tag;

- (void)dismissNotificationWithIdentifier:(NSString *)identifier;

@end
