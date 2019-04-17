//
//  NotificareReactNative.h
//  React Native Module for Notificare
//
//  Created by Joel Oliveira on 03/11/2016.
//  Copyright © 2016 Notificare. All rights reserved.
//

#import <React/RCTBridgeModule.h>
#import <React/RCTEventEmitter.h>
#import "../Libraries/NotificarePushLib/NotificarePushLib.h"

@interface NotificareReactNativeIOS : RCTEventEmitter <RCTBridgeModule>
  +(void)launch:(NSDictionary * _Nullable)launchOptions;
  +(void)setAuthorizationOptions:(UNAuthorizationOptions)options NS_AVAILABLE_IOS(10.0);
  +(void)setPresentationOptions:(UNNotificationPresentationOptions)options NS_AVAILABLE_IOS(10.0);
  +(void)setCategoryOptions:(UNNotificationCategoryOptions)options NS_AVAILABLE_IOS(10.0);
  +(void)didRegisterForRemoteNotificationsWithDeviceToken:(nonnull NSData *)deviceToken;
  +(void)didReceiveRemoteNotification:(nonnull NSDictionary *)userInfo completionHandler:(NotificareCompletionBlock)completionBlock;
  +(void)handleActionWithIdentifier:(nullable NSString *)identifier forRemoteNotification:(nonnull NSDictionary *)userInfo withResponseInfo:(nullable NSDictionary *)responseInfo completionHandler:(NotificareCompletionBlock)completionBlock;
  +(void)handleOpenURL:(nonnull NSURL *)url withOptions:(NSDictionary * _Nullable)options;
@end

@interface PushHandler : NSObject <NotificarePushLibDelegate>
@end
