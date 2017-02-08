//
//  AppDelegate.m
//  UserNotificationDemo
//
//  Created by chuanglong03 on 2016/11/4.
//  Copyright © 2016年 chuanglong. All rights reserved.
//

#import "AppDelegate.h"
#import "NotificationAction.h"
// 引入 JPush 功能所需头文件
#import "JPUSHService.h"
// iOS 10 注册 APNs 所需头文件
#ifdef NSFoundationVersionNumber_iOS_9_x_Max
#import <UserNotifications/UserNotifications.h>
#endif

#define IOS10_OR_LATER ([[[UIDevice currentDevice] systemVersion] floatValue] >= 10.0)
#define IOS9_OR_LATER ([[[UIDevice currentDevice] systemVersion] floatValue] >= 9.0)
#define IOS8_OR_LATER ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0)
#define IOS7_OR_LATER ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0)
#define IOS6_OR_LATER ([[[UIDevice currentDevice] systemVersion] floatValue] >= 6.0)

@interface AppDelegate ()<UNUserNotificationCenterDelegate, JPUSHRegisterDelegate>

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // 初始化 APNs
    [self initializeAPNs];
    // 初始化 JPush
    [self initializeJPushWithOptions:launchOptions];
    // 申请通知权限
    [self applyForNotificationAuthorization:application];
    // 注册通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(networkDidReceiveMessage:) name:kJPFNetworkDidReceiveMessageNotification object:nil];
    return YES;
}

#pragma mark - 接收到自定义消息
- (void)networkDidReceiveMessage:(NSNotification *)notification {
    NSDictionary *userInfo = notification.userInfo;
    NSLog(@"%@", userInfo);
}

#pragma mark - 初始化 APNs
- (void)initializeAPNs {
    if (IOS10_OR_LATER) {
        JPUSHRegisterEntity *entity = [[JPUSHRegisterEntity alloc] init];
        entity.types = UNAuthorizationOptionAlert | UNAuthorizationOptionBadge | UNAuthorizationOptionSound;
        [JPUSHService registerForRemoteNotificationConfig:entity delegate:self];
    } else if (IOS8_OR_LATER) {
        // 可以添加自定义 categories
        [JPUSHService registerForRemoteNotificationTypes:(UIUserNotificationTypeBadge | UIUserNotificationTypeSound | UIUserNotificationTypeAlert) categories:nil];
    } else {
        // categories 必须为 nil
        [JPUSHService registerForRemoteNotificationTypes:(UIRemoteNotificationTypeBadge |  UIRemoteNotificationTypeSound | UIRemoteNotificationTypeAlert) categories:nil];
    }
}

#pragma mark - 初始化 JPush
- (void)initializeJPushWithOptions:(NSDictionary *)launchOptions {
    NSString *appKey = @"1af5edbd3dddbf646ce37299";
    NSString *channel = @"Publish channel";
    [JPUSHService setupWithOption:launchOptions appKey:appKey channel:channel apsForProduction:NO advertisingIdentifier:nil];
}

#pragma mark - 申请通知权限
- (void)applyForNotificationAuthorization:(UIApplication *)application {
    if (IOS10_OR_LATER) {
        UNUserNotificationCenter *notificationCenter = [UNUserNotificationCenter currentNotificationCenter];
        // 必须写代理，不然无法监听通知的接收与电机事件
        notificationCenter.delegate = self;
        [notificationCenter requestAuthorizationWithOptions:(UNAuthorizationOptionAlert | UNAuthorizationOptionBadge | UNAuthorizationOptionSound) completionHandler:^(BOOL granted, NSError * _Nullable error) {
            if (!error && granted) {
                // 用户点击允许
                NSLog(@"注册成功");
            } else {
                // 用户点击不允许
                NSLog(@"注册失败");
            }
        }];
        // 获取用户的权限设置信息
        [notificationCenter getNotificationSettingsWithCompletionHandler:^(UNNotificationSettings * _Nonnull settings) {
            NSLog(@"UserSettings:%@", settings);
        }];
    } else if (IOS8_OR_LATER) {
        UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:(UIUserNotificationTypeAlert | UIUserNotificationTypeBadge | UIUserNotificationTypeSound) categories:nil];
        [application registerUserNotificationSettings:settings];
    } else {
        [application registerForRemoteNotificationTypes:(UIRemoteNotificationTypeAlert | UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound)];
    }
    [NotificationAction addNotificationActionOne];
    // 注册远端消息通知获取 device token
    [application registerForRemoteNotifications];
}

#pragma mark - 获取 device token
- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    NSString *deviceString = [[deviceToken description] stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"<>"]];
    deviceString = [deviceString stringByReplacingOccurrencesOfString:@" " withString:@""];
    NSLog(@"DeviceToken:%@", deviceString);
    // 注册 DeviceToken
    [JPUSHService registerDeviceToken:deviceToken];
}

#pragma mark - 获取 device token 失败
- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
    NSLog(@"DeviceTokenError:%@", error.description);
}

#pragma mark - iOS 10 收到通知
// app 处于前台接收通知时
- (void)userNotificationCenter:(UNUserNotificationCenter *)center willPresentNotification:(UNNotification *)notification withCompletionHandler:(void (^)(UNNotificationPresentationOptions))completionHandler {
    // 收到推送的请求
    UNNotificationRequest *request = notification.request;
    // 收到推送的内容
    UNNotificationContent *content = request.content;
    // 收到用户的基本信息
    NSDictionary *userInfo = content.userInfo;
    // 收到推送消息的角标
    NSNumber *badge = content.badge;
    // 收到推送消息的 body
    NSString *body = content.body;
    // 推送消息的声音
    UNNotificationSound *sound = content.sound;
    // 推送消息的标题
    NSString *title = content.title;
    // 推送消息的副标题
    NSString *subtitle = content.subtitle;
    // 推送类型
    UNNotificationTrigger *trigger = request.trigger;
    if ([trigger isKindOfClass:[UNPushNotificationTrigger class]]) {
        NSLog(@"iOS 10 收到远程通知：%@", userInfo);
    } else {
        NSLog(@"iOS 10 收到本地通知：{\n body:%@, \n title:%@, \n subtitle:%@, \n badge:%@, \n sound:%@, \n userInfo:%@\n}", body, title, subtitle, badge, sound, userInfo);
    }
    // 选择是否提醒用户，有 badge，sound，alert 三种类型可以设置
    completionHandler(UNNotificationPresentationOptionAlert | UNNotificationPresentationOptionBadge | UNNotificationPresentationOptionSound);
}

// app 通知的点击事件
- (void)userNotificationCenter:(UNUserNotificationCenter *)center didReceiveNotificationResponse:(UNNotificationResponse *)response withCompletionHandler:(void (^)())completionHandler {
    // 点击或输入 action
    NSString *actionIdentifier = response.actionIdentifier;
    if ([response isKindOfClass:[UNTextInputNotificationResponse class]]) {
        NSString *userText = [(UNTextInputNotificationResponse *)response userText];
        NSLog(@"actionIdentifier = %@, userText = %@", actionIdentifier, userText);
    }
    if ([actionIdentifier isEqualToString:@"action.join"]) {
        NSLog(@"actionIdentifier = %@", actionIdentifier);
    } else if ([actionIdentifier isEqualToString:@"action.look"]) {
        NSLog(@"actionIdentifier = %@", actionIdentifier);
    }
    // 收到推送请求
    UNNotificationRequest *request = response.notification.request;
    // 收到推送内容
    UNNotificationContent *content = request.content;
    // 收到用户信息
    NSDictionary *userInfo = content.userInfo;
    // 收到推送消息的角标
    NSNumber *badge = content.badge;
    // 收到推送消息的 body
    NSString *body = content.body;
    // 推送消息的声音
    UNNotificationSound *sound = content.sound;
    // 推送消息的标题
    NSString *title = content.title;
    // 推送消息的副标题
    NSString *subtitle = content.subtitle;
    // 推送类型
    UNNotificationTrigger *trigger = request.trigger;
    if ([trigger isKindOfClass:[UNPushNotificationTrigger class]]) {
        NSLog(@"iOS 10 收到远程通知：%@", userInfo);
    } else {
        NSLog(@"iOS 10 收到本地通知：{\n body:%@, \n title:%@, \n subtitle:%@, \n badge:%@, \n sound:%@, \n userInfo:%@\n}", body, title, subtitle, badge, sound, userInfo);
    }
    // 系统要求执行此方法
    completionHandler();
}

#pragma mark - JPUSHRegisterDelegate 方法
- (void)jpushNotificationCenter:(UNUserNotificationCenter *)center willPresentNotification:(UNNotification *)notification withCompletionHandler:(void (^)(NSInteger))completionHandler {
    NSDictionary *userInfo = notification.request.content.userInfo;
    if ([notification.request.trigger isKindOfClass:[UNPushNotificationTrigger class]]) {
        [JPUSHService handleRemoteNotification:userInfo];
    }
    completionHandler(UNNotificationPresentationOptionAlert | UNNotificationPresentationOptionBadge | UNNotificationPresentationOptionSound);
}

- (void)jpushNotificationCenter:(UNUserNotificationCenter *)center didReceiveNotificationResponse:(UNNotificationResponse *)response withCompletionHandler:(void (^)())completionHandler {
    NSDictionary *userInfo = response.notification.request.content.userInfo;
    if ([response.notification.request.trigger isKindOfClass:[UNPushNotificationTrigger class]]) {
        [JPUSHService handleRemoteNotification:userInfo];
    }
    completionHandler();
}

#pragma mark - iOS 10 之前收到通知
- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler {
    NSLog(@"iOS 7 及以上系统收到通知：%@", userInfo);
    [JPUSHService handleRemoteNotification:userInfo];
    completionHandler(UIBackgroundFetchResultNewData);
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
    NSLog(@"iOS 6 及以下系统收到远程通知：%@", userInfo);
    [JPUSHService handleRemoteNotification:userInfo];
}

- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification {
    NSLog(@"iOS 6 及以下系统收到本地通知：%@", notification.userInfo);
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}


- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}


@end
