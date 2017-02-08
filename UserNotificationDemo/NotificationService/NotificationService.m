//
//  NotificationService.m
//  NotificationService
//
//  Created by chuanglong03 on 2016/11/8.
//  Copyright © 2016年 chuanglong. All rights reserved.
//

#import "NotificationService.h"
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface NotificationService ()

@property (nonatomic, strong) void (^contentHandler)(UNNotificationContent *contentToDeliver);
@property (nonatomic, strong) UNMutableNotificationContent *bestAttemptContent;

@end

@implementation NotificationService

- (void)didReceiveNotificationRequest:(UNNotificationRequest *)request withContentHandler:(void (^)(UNNotificationContent * _Nonnull))contentHandler {
    self.contentHandler = contentHandler;
    self.bestAttemptContent = [request.content mutableCopy];
    // 下载图片, 放到本地
    NSString *attchUrl = [request.content.userInfo objectForKey:@"image"];
    UIImage *imageFromUrl = [self getImageFromURL:attchUrl];
    // 获取 Documents 目录
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectoryPath = [paths firstObject];
    NSString *localPath = [self saveImage:imageFromUrl withFileName:@"MyImage" ofType:@"png" inDirectory:documentsDirectoryPath];
    if (localPath && ![localPath isEqualToString:@""]) {
        UNNotificationAttachment *attachment = [UNNotificationAttachment attachmentWithIdentifier:@"photo" URL:[NSURL URLWithString:[@"file://" stringByAppendingString:localPath]] options:nil error:nil];
        if (attachment) {
            self.bestAttemptContent.attachments = @[attachment];
        }
    }
    self.contentHandler(self.bestAttemptContent);
}

- (void)serviceExtensionTimeWillExpire {
    self.contentHandler(self.bestAttemptContent);
}

#pragma mark - 获取图片
- (UIImage *)getImageFromURL:(NSString *)fileURL {
    NSLog(@"执行图片下载函数");
    UIImage *result;
    // dataWithContentsOfURL 方法需要 https 连接
    NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:fileURL]];
    result = [UIImage imageWithData:data];
    return result;
}

#pragma mark - 将所下载的图片保存到本地
- (NSString *)saveImage:(UIImage *)image withFileName:(NSString *)imageName ofType:(NSString *)extension inDirectory:(NSString *)directoryPath {
    NSString *urlStr = @"";
    if ([[extension lowercaseString] isEqualToString:@"png"]) {
        urlStr = [directoryPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.%@", imageName, @"png"]];
        [UIImagePNGRepresentation(image) writeToFile:urlStr options:NSAtomicWrite error:nil];
    } else if ([[extension lowercaseString] isEqualToString:@"jpg"] ||
               [[extension lowercaseString] isEqualToString:@"jpeg"]) {
        urlStr = [directoryPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.%@", imageName, @"jpg"]];
        [UIImageJPEGRepresentation(image, 1.0) writeToFile:urlStr options:NSAtomicWrite error:nil];
    } else {
        NSLog(@"extension error");
    }
    return urlStr;
}

@end
