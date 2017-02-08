//
//  ViewController.m
//  UserNotificationDemo
//
//  Created by chuanglong03 on 2016/11/4.
//  Copyright © 2016年 chuanglong. All rights reserved.
//

#import "ViewController.h"
#import <UserNotifications/UserNotifications.h>
#import <CoreLocation/CoreLocation.h>
#import "NotificationAction.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [self setupUpdateBtn];
    [self createLocationTimeIntervalNotification];
    [self createLocationCalendarNotification];
    [self createLocationRegionNotification];
}

#pragma mark - 更新按钮
- (void)setupUpdateBtn {
    UIButton *updateBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 80, 40)];
    updateBtn.center = self.view.center;
    [updateBtn setTitle:@"更新" forState:(UIControlStateNormal)];
    [updateBtn setTitleColor:[UIColor blackColor] forState:(UIControlStateNormal)];
    [updateBtn addTarget:self action:@selector(updateLocationNotification) forControlEvents:(UIControlEventTouchUpInside)];
    [self.view addSubview:updateBtn];
}

#pragma mark - 更新按钮点击事件
- (void)updateLocationNotification {
    UNUserNotificationCenter *notificationCenter = [UNUserNotificationCenter currentNotificationCenter];
    // 获取设备已经收到的消息推送
    [notificationCenter getDeliveredNotificationsWithCompletionHandler:^(NSArray<UNNotification *> * _Nonnull notifications) {
    }];
    // 删除设备已经收到的特定 identifier 的所有消息推送
    NSString *requestIdentifier = @"Dely.X.time";
    [notificationCenter removeDeliveredNotificationsWithIdentifiers:@[requestIdentifier]];
    // 删除设备已经收到的所有消息推送
    [notificationCenter removeAllDeliveredNotifications];
    [self createLocationTimeIntervalNotification];
}

#pragma mark - 创建时间通知
- (void)createLocationTimeIntervalNotification {
    // 设置触发条件
    UNTimeIntervalNotificationTrigger *timeIntervalTrigger = [UNTimeIntervalNotificationTrigger triggerWithTimeInterval:5 repeats:NO];
    // 创建通知内容
    UNMutableNotificationContent *content = [[UNMutableNotificationContent alloc] init];
    content.title = [NSString stringWithFormat:@"Dely 时间提醒 - title %@", [NSDate date]];
    content.subtitle = @"Dely 装逼大会竞选时间提醒 - subtitle";
    content.body = @"Dely 装逼大会总决赛时间到，欢迎你参加总决赛！希望你一统X界 - body";
    content.badge = @666;
    content.sound = [UNNotificationSound defaultSound];
    content.userInfo = @{@"key1":@"value1", @"key2":@"value2"};
    content.categoryIdentifier = @"Dely_locationCategory";
    // 创建通知请求
    NSString *requestIdentifier = @"Dely.X.time";
    UNNotificationRequest *request = [UNNotificationRequest requestWithIdentifier:requestIdentifier content:content trigger:timeIntervalTrigger];
    // 将通知请求添加到通知中心
    UNUserNotificationCenter *notificationCenter = [UNUserNotificationCenter currentNotificationCenter];
    [notificationCenter addNotificationRequest:request withCompletionHandler:^(NSError * _Nullable error) {
        if (!error) {
            NSLog(@"推送已添加成功：%@", requestIdentifier);
        }
    }];
}

#pragma mark - 创建日期通知
- (void)createLocationCalendarNotification {
    // 创建日期
    NSDateComponents *dateComponents = [[NSDateComponents alloc] init];
    dateComponents.weekday = 4;
    dateComponents.hour = 10;
    dateComponents.minute = 10;
    UNCalendarNotificationTrigger *calendarTrigger = [UNCalendarNotificationTrigger triggerWithDateMatchingComponents:dateComponents repeats:YES];
    // 创建通知内容
    UNMutableNotificationContent *content = [[UNMutableNotificationContent alloc] init];
    content.title = @"时间提醒";
    content.subtitle = @"装X时间";
    content.body = @"您的装X时间所剩不多请到服务台续费！";
    content.badge = @666;
    // 创建通知请求
    NSString *requestIdentifier = @"Dely.y.time";
    UNNotificationRequest *request = [UNNotificationRequest requestWithIdentifier:requestIdentifier content:content trigger:calendarTrigger];
    // 将通知请求添加到通知中心
    UNUserNotificationCenter *notificationCenter = [UNUserNotificationCenter currentNotificationCenter];
    [notificationCenter addNotificationRequest:request withCompletionHandler:^(NSError * _Nullable error) {
        if (!error) {
            NSLog(@"推送已缇娜集成功：%@", requestIdentifier);
        }
    }];
}

#pragma mark - 创建地区通知
- (void)createLocationRegionNotification {
    // 创建位置信息
    CLLocationCoordinate2D coordinate2D = CLLocationCoordinate2DMake(39.788857, 116.5559392);
    CLCircularRegion *region = [[CLCircularRegion alloc] initWithCenter:coordinate2D radius:500 identifier:@"静海五路"];
    region.notifyOnEntry = YES;
    region.notifyOnExit = YES;
    UNLocationNotificationTrigger *regionTrigger = [UNLocationNotificationTrigger triggerWithRegion:region repeats:YES];
    // 创建通知内容
    UNMutableNotificationContent *content = [[UNMutableNotificationContent alloc] init];
    content.title = @"地点到了老司机";
    content.subtitle = @"装X时间";
    content.body = @"您的装X时间所剩不多请到服务台续费！";
    content.badge = @1;
    // 创建通知请求
    NSString *requestIdentifier = @"zhuangbility.time.of.tony";
    UNNotificationRequest *request = [UNNotificationRequest requestWithIdentifier:requestIdentifier content:content trigger:regionTrigger];
    // 将通知请求添加到通知中心
    UNUserNotificationCenter *notificationCenter = [UNUserNotificationCenter currentNotificationCenter];
    [notificationCenter addNotificationRequest:request withCompletionHandler:^(NSError * _Nullable error) {
        if (!error) {
            NSLog(@"推送已添加成功：%@", requestIdentifier);
        }
    }];
}

@end
