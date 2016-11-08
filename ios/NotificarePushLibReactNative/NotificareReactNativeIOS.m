//
//  NotificareReactNative.m
//  React Native Module for Notificare
//
//  Created by Joel Oliveira on 03/11/2016.
//  Copyright © 2016 Notificare. All rights reserved.
//
#import "RCTBridge.h"
#import "NotificareReactNativeIOS.h"
#import "RCTLog.h"

@implementation NotificareReactNativeIOS

@synthesize bridge = _bridge; 

static NotificareReactNativeIOS *instance = nil;
static PushHandler *pushHandler = nil;

+ (NotificareReactNativeIOS *)getInstance {
  return instance;
}

+ (PushHandler *)getPushHandler {
  return pushHandler;
}

+ (void)launch:(NSDictionary *)launchOptions {
  
  NSUserDefaults * defaults = [NSUserDefaults standardUserDefaults];
  [defaults setObject:launchOptions forKey:@"notificareLaunchOptions"];
  [defaults synchronize];

}

+ (void)handleNotification:(NSDictionary *)notification forApplication:(UIApplication *)application completionHandler:(SuccessBlock)result errorHandler:(ErrorBlock)errorBlock{

    [[NotificarePushLib shared] handleNotification:notification forApplication:application completionHandler:^(NSDictionary * _Nonnull info) {
      //
      [[NotificareReactNativeIOS getInstance] dispatchEvent:@"onNotificationReceived" body:notification];
      result(info);
    } errorHandler:^(NSError * _Nonnull error) {
      //
      errorBlock(error);
    }];
}

+ (void)registerDevice:(NSData *)deviceToken withUserID:(NSString *)userID withUserName:(NSString *)userName completionHandler:(SuccessBlock)result errorHandler:(ErrorBlock)errorBlock {
  
  if (userID && userName) {
  
    [[NotificarePushLib shared] registerDevice:deviceToken withUserID:userID withUsername:userName completionHandler:^(NSDictionary * _Nonnull info) {
      [[NotificareReactNativeIOS getInstance] dispatchEvent:@"didRegisterDevice" body:@{@"device": [deviceToken hexadecimalString]}];
      result(info);
    } errorHandler:^(NSError * _Nonnull error) {
      errorBlock(error);
    }];
    
  } else if (userID && !userName) {
    
    [[NotificarePushLib shared] registerDevice:deviceToken withUserID:userID completionHandler:^(NSDictionary * _Nonnull info) {
      [[NotificareReactNativeIOS getInstance] dispatchEvent:@"didRegisterDevice" body:@{@"device": [deviceToken hexadecimalString]}];
      result(info);
    } errorHandler:^(NSError * _Nonnull error) {
      errorBlock(error);
    }];
    
  } else {
    
    [[NotificarePushLib shared] registerDevice:deviceToken completionHandler:^(NSDictionary * _Nonnull info) {
      [[NotificareReactNativeIOS getInstance] dispatchEvent:@"didRegisterDevice" body:@{@"device": [deviceToken hexadecimalString]}];
      result(info);
    } errorHandler:^(NSError * _Nonnull error) {
      errorBlock(error);
    }];
    
  }
  
}


- (NSArray<NSString*> *)supportedEvents {
  return @[@"onNotificationReceived", @"onNotificationClicked", @"onReady", @"didUpdateBadge", @"didReceiveSystemPush", @"didLoadStore", @"didRegisterDevice"];
}

- (dispatch_queue_t)methodQueue
{
  instance = self;
  return dispatch_get_main_queue();
}

- (void)dispatchEvent:(NSString *)event body:(NSDictionary *)notification {
  [self sendEventWithName:event body:notification];
}

RCT_EXPORT_MODULE()


RCT_EXPORT_METHOD(launch){
  NSUserDefaults * defaults = [NSUserDefaults standardUserDefaults];
  pushHandler = [[PushHandler alloc] init];
  [[NotificarePushLib shared] launch];
  [[NotificarePushLib shared] setDelegate:pushHandler];
  [[NotificarePushLib shared] handleOptions:[defaults objectForKey:@"notificareLaunchOptions"]];
  [defaults setObject:nil forKey:@"notificareLaunchOptions"];
  [defaults synchronize];
}

RCT_EXPORT_METHOD(registerForNotifications) {
  
  [[NotificarePushLib shared] registerForNotifications];
  
}

RCT_EXPORT_METHOD(startLocationUpdates) {
  
  [[NotificarePushLib shared] startLocationUpdates];
  
}

RCT_EXPORT_METHOD(registerDevice:(NSString *)deviceToken userID:(NSString *)userID userName:(NSString *)userName callback:(RCTResponseSenderBlock)callback) {
  
  NSMutableData *token = [[NSMutableData alloc] init];
  unsigned char whole_byte;
  char byte_chars[3] = { '\0', '\0', '\0' };
  int i;
  for (i=0; i<[deviceToken length]/2; i++) {
    byte_chars[0] = [deviceToken characterAtIndex:i*2];
    byte_chars[1] = [deviceToken characterAtIndex:i*2+1];
    whole_byte = strtol(byte_chars, NULL, 16);
    [token appendBytes:&whole_byte length:1];
  }
  
  if (userID && userName) {
    
    [[NotificarePushLib shared] registerDevice:token withUserID:userID withUsername:userName completionHandler:^(NSDictionary * _Nonnull info) {
      [[NotificareReactNativeIOS getInstance] dispatchEvent:@"didRegisterDevice" body:@{@"device": token}];
      callback(@[[NSNull null], info]);
    } errorHandler:^(NSError * _Nonnull error) {
      callback(@[error, [NSNull null]]);
    }];
    
  } else if (userID && !userName) {
    
    [[NotificarePushLib shared] registerDevice:token withUserID:userID completionHandler:^(NSDictionary * _Nonnull info) {
      [[NotificareReactNativeIOS getInstance] dispatchEvent:@"didRegisterDevice" body:@{@"device": token}];
      callback(@[[NSNull null], info]);
    } errorHandler:^(NSError * _Nonnull error) {
      callback(@[error, [NSNull null]]);
    }];
    
  } else {
    
    [[NotificarePushLib shared] registerDevice:token completionHandler:^(NSDictionary * _Nonnull info) {
      [[NotificareReactNativeIOS getInstance] dispatchEvent:@"didRegisterDevice" body:@{@"device": token}];
      callback(@[[NSNull null], info]);
    } errorHandler:^(NSError * _Nonnull error) {
      callback(@[error, [NSNull null]]);
    }];
    
  }
  
}

RCT_EXPORT_METHOD(fetchDevice:(RCTResponseSenderBlock)callback) {
  NotificareDevice * device = [[NotificarePushLib shared] myDevice];
  NSMutableDictionary * info = [NSMutableDictionary new];
  [info setObject:[device deviceID] forKey:@"deviceID"];
  [info setObject:[device username] forKey:@"username"];
  [info setObject:[device userID] forKey:@"userID"];
  [info setObject:[device userData] forKey:@"userData"];
  callback(@[[NSNull null], info]);
}

RCT_EXPORT_METHOD(fetchTags:(RCTResponseSenderBlock)callback) {
  
  [[NotificarePushLib shared] getTags:^(NSDictionary * _Nonnull info) {
    callback(@[[NSNull null], info]);
  } errorHandler:^(NSError * _Nonnull error) {
    callback(@[error, [NSNull null]]);
  }];
  
}


RCT_EXPORT_METHOD(addTags:(NSArray *)tags callback:(RCTResponseSenderBlock)callback) {
  
  [[NotificarePushLib shared] addTags:tags completionHandler:^(NSDictionary * _Nonnull info) {
    callback(@[[NSNull null], info]);
  } errorHandler:^(NSError * _Nonnull error) {
    callback(@[error, [NSNull null]]);
  }];

}

RCT_EXPORT_METHOD(removeTag:(NSString *)tag callback:(RCTResponseSenderBlock)callback) {
  
  [[NotificarePushLib shared] removeTag:tag completionHandler:^(NSDictionary * _Nonnull info) {
    callback(@[[NSNull null], info]);
  } errorHandler:^(NSError * _Nonnull error) {
    callback(@[error, [NSNull null]]);
  }];
  
}

RCT_EXPORT_METHOD(clearTags:(RCTResponseSenderBlock)callback) {
  
  [[NotificarePushLib shared] clearTags:^(NSDictionary * _Nonnull info) {
    callback(@[[NSNull null], info]);
  } errorHandler:^(NSError * _Nonnull error) {
    callback(@[error, [NSNull null]]);
  }];
  
}


RCT_EXPORT_METHOD(openNotification:(NSDictionary *)notification) {
  
  [[NotificarePushLib shared] openNotification:notification];
  
}

RCT_EXPORT_METHOD(fetchInbox:(NSDate*)since skip:(NSNumber* _Nonnull)skip limit:(NSNumber* _Nonnull)limit callback:(RCTResponseSenderBlock)callback) {
  
  [[NotificarePushLib shared] fetchInbox:since skip:skip limit:limit completionHandler:^(NSDictionary * _Nonnull info) {
    
    NSMutableArray * items = [NSMutableArray new];
    for (NotificareDeviceInbox * item in [info objectForKey:@"inbox"]) {
      NSMutableDictionary * inboxItem = [NSMutableDictionary new];
      [inboxItem setObject:[item inboxId] forKey:@"inboxId"];
      [inboxItem setObject:[item notification] forKey:@"notification"];
      [inboxItem setObject:[item message] forKey:@"message"];
      [inboxItem setObject:[item time] forKey:@"time"];
      [inboxItem setObject:[NSNumber numberWithBool:[item opened]] forKey:@"opened"];
      [items addObject:inboxItem];
    }
    
    callback(@[[NSNull null], items]);
  } errorHandler:^(NSError * _Nonnull error) {
    callback(@[error, [NSNull null]]);
  }];
  
}

RCT_EXPORT_METHOD(openInboxItem:(NSDictionary*)inboxItem) {
  
  NotificareDeviceInbox * item = [NotificareDeviceInbox new];
  [item setInboxId:[inboxItem objectForKey:@"inboxId"]];
  [item setNotification:[inboxItem objectForKey:@"notification"]];
  [item setMessage:[inboxItem objectForKey:@"message"]];
  [[NotificarePushLib shared] openInboxItem:item];
  
}

RCT_EXPORT_METHOD(removeFromInbox:(NSDictionary*)inboxItem callback:(RCTResponseSenderBlock)callback) {
  
  NotificareDeviceInbox * item = [NotificareDeviceInbox new];
  [item setInboxId:[inboxItem objectForKey:@"inboxId"]];
  [item setNotification:[inboxItem objectForKey:@"notification"]];
  [item setMessage:[inboxItem objectForKey:@"message"]];
  
  [[NotificarePushLib shared] removeFromInbox:item completionHandler:^(NSDictionary * _Nonnull info) {
    callback(@[[NSNull null], info]);
  } errorHandler:^(NSError * _Nonnull error) {
    callback(@[error, [NSNull null]]);
  }];
  
}

RCT_EXPORT_METHOD(markAsRead:(NSDictionary*)inboxItem callback:(RCTResponseSenderBlock)callback) {
  
  NotificareDeviceInbox * item = [NotificareDeviceInbox new];
  [item setInboxId:[inboxItem objectForKey:@"inboxId"]];
  [item setNotification:[inboxItem objectForKey:@"notification"]];
  [item setMessage:[inboxItem objectForKey:@"message"]];
  
  [[NotificarePushLib shared] markAsRead:item completionHandler:^(NSDictionary * _Nonnull info) {
    callback(@[[NSNull null], info]);
  } errorHandler:^(NSError * _Nonnull error) {
    callback(@[error, [NSNull null]]);
  }];
  
}

@end

@implementation PushHandler

-(void)notificarePushLib:(NotificarePushLib *)library onReady:(NSDictionary *)info{

  [[NotificareReactNativeIOS getInstance] dispatchEvent:@"onReady" body:info];
  
}

-(void)notificarePushLib:(NotificarePushLib *)library willHandleNotification:(UNNotification *)notification{
  
  [[NotificareReactNativeIOS getInstance] dispatchEvent:@"onNotificationClicked" body:notification.request.content.userInfo];
  
}

- (void)notificarePushLib:(NotificarePushLib *)library didReceiveSystemPush:(nonnull NSDictionary *)info{
  [[NotificareReactNativeIOS getInstance] dispatchEvent:@"didReceiveSystemPush" body:info];
}

-(void)notificarePushLib:(NotificarePushLib *)library didUpdateBadge:(int)badge{
  
  NSMutableDictionary * info = [NSMutableDictionary new];
  [info setObject:[NSNumber numberWithInt:badge] forKey:@"badge"];
  [[NotificareReactNativeIOS getInstance] dispatchEvent:@"didUpdateBadge" body:info];
  
}

-(void)notificarePushLib:(NotificarePushLib *)library didLoadStore:(NSArray *)products{
  
  [[NotificareReactNativeIOS getInstance] dispatchEvent:@"didLoadStore" body:@{@"products":products}];
  
}


@end
