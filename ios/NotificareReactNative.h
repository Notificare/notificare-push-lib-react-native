//
//  NotificareReactNative.h
//  React Native Module for Notificare
//
//  Created by Joel Oliveira on 03/11/2016.
//  Copyright © 2016 Notificare. All rights reserved.
//

#import "RCTBridgeModule.h"
#import "NotificarePushLib.h"

@interface NotificareReactNative : NSObject <RCTBridgeModule>
 +(void)launch:(NSDictionary *)launchOptions;
@end

@interface PushHandler : NSObject <NotificarePushLibDelegate>
@end
