//
//  NotificareReactNative.h
//  React Native Module for Notificare
//
//  Created by Joel Oliveira on 03/11/2016.
//  Copyright © 2016 Notificare. All rights reserved.
//

#import "RCTBridgeModule.h"
#import "RCTEventEmitter.h"
#import "NotificarePushLib.h"

@interface NotificareReactNativeIOS : RCTEventEmitter <RCTBridgeModule>
  +(void)launch:(NSDictionary *)launchOptions;
  +(void)registerDevice:(NSData *)deviceToken withUserID:(NSString *)userID withUserName:(NSString *)userName completionHandler:(SuccessBlock)result errorHandler:(ErrorBlock)errorBlock;
  +(void)handleNotification:(NSDictionary *)notification forApplication:(UIApplication *)application completionHandler:(SuccessBlock)result errorHandler:(ErrorBlock)errorBlock;
@end

@interface PushHandler : NSObject <NotificarePushLibDelegate>
@end
