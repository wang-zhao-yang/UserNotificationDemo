//
//  NotificationViewController.m
//  NotificationContent
//
//  Created by chuanglong03 on 2016/11/8.
//  Copyright © 2016年 chuanglong. All rights reserved.
//

#import "NotificationViewController.h"
#import <UserNotifications/UserNotifications.h>
#import <UserNotificationsUI/UserNotificationsUI.h>

@interface NotificationViewController () <UNNotificationContentExtension>

@property IBOutlet UILabel *label;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;

@end

@implementation NotificationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)didReceiveNotification:(UNNotification *)notification {
    self.label.text = notification.request.content.body;
    UNNotificationContent *content = notification.request.content;
    UNNotificationAttachment *attachment = content.attachments.firstObject;
    if (attachment.URL.startAccessingSecurityScopedResource) {
        self.imageView.image = [UIImage imageWithContentsOfFile:attachment.URL.path];
    }
}

@end
