//
//  NotificationAction.m
//  UserNotificationDemo
//
//  Created by chuanglong03 on 2016/11/8.
//  Copyright © 2016年 chuanglong. All rights reserved.
//

#import "NotificationAction.h"
#ifdef NSFoundationVersionNumber_iOS_9_x_Max
#import <UserNotifications/UserNotifications.h>
#endif

@implementation NotificationAction

+ (void)addNotificationActionOne {
    // 创建 action
    UNNotificationAction *joinAction = [UNNotificationAction actionWithIdentifier:@"action.join" title:@"接收邀请" options:(UNNotificationActionOptionAuthenticationRequired)];
    UNNotificationAction *lookAction = [UNNotificationAction actionWithIdentifier:@"action.look" title:@"查看邀请" options:(UNNotificationActionOptionForeground)];
    UNNotificationAction *cancelAction = [UNNotificationAction actionWithIdentifier:@"action.cancel" title:@"取消" options:(UNNotificationActionOptionDestructive)];
    // 注册 category
    /* 
     * identifier 标识符
     * actions 操作数组
     * intentIdentifiers 意图标识符，可在 <Intents/INIntentIdentifiers.h> 中查看，主要是针对电话、carplay 等开放的 API
     * options 通知选项，枚举类型，也是为了支持 carplay
     */
    UNNotificationCategory *notificationCategory = [UNNotificationCategory categoryWithIdentifier:@"Dely_locationCategory" actions:@[joinAction, lookAction, cancelAction] intentIdentifiers:@[] options:(UNNotificationCategoryOptionCustomDismissAction)];
    // 将 category 添加到通知中心
    UNUserNotificationCenter *notificationCenter = [UNUserNotificationCenter currentNotificationCenter];
    [notificationCenter setNotificationCategories:[NSSet setWithObject:notificationCategory]];
}

+ (void)addNotificationActionTwo {
    // 创建 UNTextInputNotificationAction
    UNTextInputNotificationAction *inputAction = [UNTextInputNotificationAction actionWithIdentifier:@"action.input" title:@"输入" options:(UNNotificationActionOptionForeground) textInputButtonTitle:@"发送" textInputPlaceholder:@"tell me loudly"];
    // 注册 category
    UNNotificationCategory *notificationCategory = [UNNotificationCategory categoryWithIdentifier:@"Dely_locationCategory" actions:@[inputAction] intentIdentifiers:@[] options:(UNNotificationCategoryOptionCustomDismissAction)];
    // 将 category 添加到通知中心
    UNUserNotificationCenter *notificationCenter = [UNUserNotificationCenter currentNotificationCenter];
    [notificationCenter setNotificationCategories:[NSSet setWithObject:notificationCategory]];
}

@end
