//
//  NotificareReactNative.h
//  React Native Module for Notificare
//
//  Created by Joel Oliveira on 03/11/2016.
//  Copyright © 2016 Notificare. All rights reserved.
//

#import <React/RCTBridgeModule.h>
#import <React/RCTEventEmitter.h>
#import "../Libraries/notificare-push-lib/NotificarePushLib.h"

@interface NotificareReactNativeIOS : RCTEventEmitter <RCTBridgeModule>
  +(void)launch:(NSDictionary *)launchOptions;
  +(void)registerDevice:(NSData *)deviceToken completionHandler:(SuccessBlock)result errorHandler:(ErrorBlock)errorBlock;
  +(void)handleNotification:(NSDictionary *)notification forApplication:(UIApplication *)application completionHandler:(SuccessBlock)result errorHandler:(ErrorBlock)errorBlock;
  + (void)handleAction:(NSString *)identifier forNotification:(NSDictionary *)userInfo withData:(NSDictionary *)data completionHandler:(SuccessBlock)result errorHandler:(ErrorBlock)errorBlock;
  + (void)handleOpenURL:(NSURL *)url;
@end

@interface PushHandler : NSObject <NotificarePushLibDelegate>
@end
