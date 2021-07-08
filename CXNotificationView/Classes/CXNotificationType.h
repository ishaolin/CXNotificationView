//
//  GLNotificationType.h
//  Pods
//
//  Created by wshaolin on 2018/6/29.
//

#ifndef GLNotificationType_h
#define GLNotificationType_h

#import <UIKit/UIKit.h>
#import <CXFoundation/CXFoundation.h>

@class CXNotificationView;

typedef NS_ENUM(NSInteger, CXNotificationViewCloseType) {
    CXNotificationViewCloseTypeUnknown,         // 未知或当前卡片未进入关闭流程
    CXNotificationViewCloseTypeDurationDeplete, // 展示时长用尽
    CXNotificationViewCloseTypeUpDraged,        // 手势上拉关闭
    CXNotificationViewCloseTypeClickedSelf,     // 点击消息体关闭
    CXNotificationViewCloseTypeExternalDismiss  // 外部调用dismiss关闭
};

// notification能否展示
typedef BOOL (^CXNotificationShouldDisplayBlock)(CXNotificationView *view);
// notification即将展示
typedef void (^CXNotificationWillDisplayBlock)(CXNotificationView *view);
// notification已经展示
typedef void (^CXNotificationDidDisplayBlock)(CXNotificationView *view);
// notification点击事件
typedef void (^CXNotificationSimpleActionBlock)(CXNotificationView *view);
// notification即将关闭
typedef void (^CXNotificationWillCloseBlock)(CXNotificationView *view);
// notification已经关闭
typedef void (^CXNotificationDidCloseBlock)(CXNotificationView *view);

#endif /* GLNotificationType_h */
