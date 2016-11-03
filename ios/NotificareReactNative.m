//
//  NotificareReactNative.m
//  React Native Module for Notificare
//
//  Created by Joel Oliveira on 03/11/2016.
//  Copyright © 2016 Notificare. All rights reserved.
//
#import "RCTBridge.h"
#import "RCTEventDispatcher.h"
#import "NotificareReactNative.h"

@implementation NotificareReactNative

@synthesize bridge = _bridge;

static NotificareReactNative *instance = nil;
static PushHandler *pushHandler = nil;

+ (NotificareReactNative *)getInstance {
  return instance;
}

+ (PushHandler *)getPushHandler {
  return pushHandler;
}

+ (void)launch:(NSDictionary *)launchOptions {
  [[NotificarePushLib shared] launch];
  [[NotificarePushLib shared] setDelegate:pushHandler];
  [[NotificarePushLib shared] handleOptions:launchOptions];
}


- (dispatch_queue_t)methodQueue
{
  return dispatch_get_main_queue();
}

- (void)dispatchEvent:(NSString *)event body:(NSDictionary *)notification {
  [self.bridge.eventDispatcher sendAppEventWithName:event body:notification];
}

RCT_EXPORT_MODULE()

RCT_EXPORT_METHOD(registerForNotifications) {
  
  [[NotificarePushLib shared] registerForNotifications];
  
}

RCT_EXPORT_METHOD(startLocationUpdates) {
  
  [[NotificarePushLib shared] startLocationUpdates];
  
}

RCT_EXPORT_METHOD(addTags:(NSArray *)tags:(RCTResponseSenderBlock)callback) {
  
  [[NotificarePushLib shared] addTags:tags completionHandler:^(NSDictionary * _Nonnull info) {
    callback(@[[NSNull null], info]);
  } errorHandler:^(NSError * _Nonnull error) {
    callback(@[[NSNull null], error]);
  }];

}


@end

@implementation PushHandler

-(void)notificarePushLib:(NotificarePushLib *)library onReady:(NSDictionary *)info{

  [[NotificareReactNative getInstance] dispatchEvent:@"onReady" body:info];
  
}

@end
