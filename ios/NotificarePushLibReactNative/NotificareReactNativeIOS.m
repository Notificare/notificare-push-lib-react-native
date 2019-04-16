//
//  NotificareReactNative.m
//  React Native Module for Notificare
//
//  Created by Joel Oliveira on 03/11/2016.
//  Copyright © 2016 Notificare. All rights reserved.
//
#import <React/RCTBridge.h>
#import "NotificareReactNativeIOS.h"
#import <React/RCTLog.h>
#import <React/RCTUtils.h>
#import "NotificareReactNativeIOSUtils.h"

@implementation NotificareReactNativeIOS

@synthesize bridge = _bridge;

static NotificareReactNativeIOS *instance = nil;
static PushHandler *pushHandler = nil;
static UNAuthorizationOptions authorizationOptions = UNAuthorizationOptionBadge + UNAuthorizationOptionSound + UNAuthorizationOptionAlert;
static UNNotificationPresentationOptions presentationOptions = UNNotificationPresentationOptionNone;
static UNNotificationCategoryOptions categoryOptions = UNNotificationCategoryOptionCustomDismissAction;

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

+ (void)setAuthorizationOptions:(UNAuthorizationOptions)options {
    authorizationOptions = options;
}

+ (void)setPresentationOptions:(UNNotificationPresentationOptions)options {
    presentationOptions = options;
}

+ (void)setCategoryOptions:(UNNotificationCategoryOptions)options {
    categoryOptions = options;
}

+ (void)didRegisterForRemoteNotificationsWithDeviceToken:(nonnull NSData *)deviceToken{
    [[NotificarePushLib shared] didRegisterForRemoteNotificationsWithDeviceToken:deviceToken];
}

+ (void)didReceiveRemoteNotification:(NSDictionary *)userInfo completionHandler:(NotificareCompletionBlock)completionBlock{
    [[NotificarePushLib shared] didReceiveRemoteNotification:userInfo completionHandler:^(id  _Nullable response, NSError * _Nullable error) {
        completionBlock(response, error);
    }];
}

+ (void)handleActionWithIdentifier:(nullable NSString *)identifier forRemoteNotification:(nonnull NSDictionary *)userInfo withResponseInfo:(nullable NSDictionary *)responseInfo completionHandler:(NotificareCompletionBlock)completionBlock{
    [[NotificarePushLib shared] handleActionWithIdentifier:identifier forRemoteNotification:userInfo withResponseInfo:responseInfo completionHandler:^(id  _Nullable response, NSError * _Nullable error) {
        completionBlock(response, error);
    }];
}

+ (void)handleOpenURL:(nonnull NSURL *)url withOptions:(NSDictionary * _Nullable)options{
    [[NotificarePushLib shared] handleOpenURL:url withOptions:options];
    NSMutableDictionary * payload = [NSMutableDictionary new];
    [payload setObject:[url absoluteString] forKey:@"url"];
    [payload setObject:options forKey:@"options"];
    [[NotificareReactNativeIOS getInstance] dispatchEvent:@"notificare:willOpenURL" body:payload];
}

- (NSArray<NSString*> *)supportedEvents {
    return @[
             @"notificare:willOpenURL",
             @"notificare:onReady"
            ];
}


//- (NSArray<NSString*> *)supportedEvents {
//    return @[@"notificationReceived", @"notificationOpened", @"ready", @"badge", @"systemPush", @"didLoadStore", @"didFailToLoadStore", @"didReceiveDeviceToken", @"willOpenURL", @"willOpenNotification", @"didOpenNotification", @"didClickURL", @"didCloseNotification", @"didFailToOpenNotification", @"willExecuteAction", @"didExecuteAction", @"shouldPerformSelectorWithURL", @"didNotExecuteAction", @"didFailToExecuteAction", @"didReceiveLocationServiceAuthorizationStatus", @"didFailToStartLocationServiceWithError", @"didUpdateLocations", @"monitoringDidFailForRegion", @"didDetermineState", @"didEnterRegion", @"didExitRegion", @"didStartMonitoringForRegion", @"rangingBeaconsDidFailForRegion", @"didRangeBeacons", @"didFailProductTransaction", @"didCompleteProductTransaction", @"didRestoreProductTransaction", @"didStartDownloadContent", @"didPauseDownloadContent", @"didCancelDownloadContent", @"didReceiveProgressDownloadContent", @"didFailDownloadContent", @"didFinishDownloadContent", @"didChangeAccountNotification", @"didFailToRequestAccessNotification", @"didValidateAccount", @"didFailToValidateAccount", @"didReceiveResetPasswordToken"];
//}

- (dispatch_queue_t)methodQueue
{
  instance = self;
  return dispatch_get_main_queue();
}

- (void)dispatchEvent:(NSString *)event body:(NSDictionary *)notification {
  [self sendEventWithName:event body:notification];
}


RCT_EXPORT_MODULE()

RCT_EXPORT_METHOD(initializeWithKey:(NSString * _Nullable)key andSecret:(NSString * _Nullable)secret){
    [[NotificarePushLib shared] initializeWithKey:key andSecret:secret];
}

RCT_EXPORT_METHOD(launch){
    NSUserDefaults * defaults = [NSUserDefaults standardUserDefaults];
    pushHandler = [[PushHandler alloc] init];
    [[NotificarePushLib shared] launch];
    [[NotificarePushLib shared] setDelegate:pushHandler];
    [[NotificarePushLib shared] didFinishLaunchingWithOptions:[defaults objectForKey:@"notificareLaunchOptions"]];
    [defaults setObject:nil forKey:@"notificareLaunchOptions"];
    [defaults synchronize];

    if (authorizationOptions) {
        [[NotificarePushLib shared] setAuthorizationOptions:authorizationOptions];
    }

    if (presentationOptions) {
        [[NotificarePushLib shared] setPresentationOptions:presentationOptions];
    }
    
    if (categoryOptions) {
        [[NotificarePushLib shared] setCategoryOptions:categoryOptions];
    }
}

RCT_EXPORT_METHOD(registerForNotifications) {
  [[NotificarePushLib shared] registerForNotifications];
}

RCT_EXPORT_METHOD(unregisterForNotifications) {
    [[NotificarePushLib shared] unregisterForNotifications];
}

RCT_REMAP_METHOD(isRemoteNotificationsEnabled, isRemoteNotificationsEnabledWithResolver:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject) {
    resolve(@([[NotificarePushLib shared] remoteNotificationsEnabled]));
}

RCT_REMAP_METHOD(isAllowedUIEnabled, isAllowedUIEnabledWithResolver:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject) {
    resolve(@([[NotificarePushLib shared] allowedUIEnabled]));
}

RCT_REMAP_METHOD(isNotificationFromNotificare, userInfo:(nonnull NSDictionary *)userInfo isNotificationFromNotificareWithResolver:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject) {
    resolve(@([[NotificarePushLib shared] isNotificationFromNotificare:userInfo]));
}

RCT_REMAP_METHOD(fetchNotificationSettings, fetchNotificationSettingsWithResolver:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject) {
    
    [[[NotificarePushLib shared] userNotificationCenter] getNotificationSettingsWithCompletionHandler:^(UNNotificationSettings * _Nonnull settings) {
        NSMutableDictionary * payload = [NSMutableDictionary new];
        BOOL status = NO;
        if ([settings authorizationStatus] == UNAuthorizationStatusAuthorized) {
            status = YES;
        }
        [payload setObject:[NSNumber numberWithBool:status] forKey:@"granted"];
        resolve(payload);
    }];
}


RCT_EXPORT_METHOD(startLocationUpdates) {
  
  [[NotificarePushLib shared] startLocationUpdates];
  
}

RCT_EXPORT_METHOD(stopLocationUpdates) {
    
    [[NotificarePushLib shared] stopLocationUpdates];
    
}

RCT_REMAP_METHOD(registerDevice, userID:(NSString * _Nullable)userID userName:(NSString * _Nullable)userName registerDeviceWithResolver:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject) {
    
    [[NotificarePushLib shared] registerDevice:userID withUsername:userName completionHandler:^(id  _Nullable response, NSError * _Nullable error) {
        if (!error) {
            resolve(response);
        } else {
           reject(@"error", [error description], error);
        }
    }];
}

RCT_REMAP_METHOD(fetchDevice, fetchDeviceWithResolver:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject) {
    NotificareDevice * device = [[NotificarePushLib shared] myDevice];
    resolve([[NotificareReactNativeIOSUtils shared] dictionaryFromDevice:device]);
}

RCT_REMAP_METHOD(fetchPreferredLanguage, fetchPreferredLanguageWithResolver:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject) {
    resolve([[NotificarePushLib shared] preferredLanguage]);
}

RCT_REMAP_METHOD(updatePreferredLanguage, preferredLanguage:(NSString * _Nullable)preferredLanguage updatePreferredLanguageWithResolver:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject) {
    
    [[NotificarePushLib shared] updatePreferredLanguage:preferredLanguage completionHandler:^(id  _Nullable response, NSError * _Nullable error) {
        if (!error) {
            resolve(response);
        } else {
            reject(@"error", [error description], error);
        }
    }];
    
}

RCT_REMAP_METHOD(fetchTags, fetchTagsWithResolver:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject) {
    
    [[NotificarePushLib shared] fetchTags:^(id  _Nullable response, NSError * _Nullable error) {
        if (!error) {
            resolve(response);
        } else {
            reject(@"error", [error description], error);
        }
    }];
    
}

RCT_REMAP_METHOD(addTag, tag:(nonnull NSString *)tag addTagWithResolver:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject) {
    
    [[NotificarePushLib shared] addTag:tag completionHandler:^(id  _Nullable response, NSError * _Nullable error) {
        if (!error) {
            resolve(response);
        } else {
            reject(@"error", [error description], error);
        }
    }];
}

RCT_REMAP_METHOD(addTags, tags:(nonnull NSArray *)tags addTagsWithResolver:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject) {
    
    [[NotificarePushLib shared] addTags:tags completionHandler:^(id  _Nullable response, NSError * _Nullable error) {
        if (!error) {
            resolve(response);
        } else {
            reject(@"error", [error description], error);
        }
    }];
}

RCT_REMAP_METHOD(removeTag, tag:(nonnull NSString *)tag removeTagWithResolver:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject) {
    
    [[NotificarePushLib shared] removeTag:tag completionHandler:^(id  _Nullable response, NSError * _Nullable error) {
        if (!error) {
            resolve(response);
        } else {
            reject(@"error", [error description], error);
        }
    }];
}


RCT_REMAP_METHOD(removeTags, tags:(nonnull NSArray *)tags removeTagsWithResolver:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject) {
    
    [[NotificarePushLib shared] removeTags:tags completionHandler:^(id  _Nullable response, NSError * _Nullable error) {
        if (!error) {
            resolve(response);
        } else {
            reject(@"error", [error description], error);
        }
    }];
}

RCT_REMAP_METHOD(clearTags, clearTagsWithResolver:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject) {
    
    [[NotificarePushLib shared] clearTags:^(id  _Nullable response, NSError * _Nullable error) {
        if (!error) {
            resolve(response);
        } else {
            reject(@"error", [error description], error);
        }
    }];

}

RCT_REMAP_METHOD(fetchUserData, fetchUserDataWithResolver:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject) {
    
    [[NotificarePushLib shared] fetchUserData:^(id  _Nullable response, NSError * _Nullable error) {
        if (!error) {
            NSMutableArray * payload = [NSMutableArray array];
            for (NotificareUserData * userData in response) {
                [payload addObject:[[NotificareReactNativeIOSUtils shared] dictionaryFromUserData:userData]];
            }
            resolve(payload);
        } else {
            reject(@"error", [error description], error);
        }
    }];
    
}

RCT_REMAP_METHOD(updateUserData, userData:(nonnull NSArray *)userData updateUserDataWithResolver:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject) {
    
    NSMutableArray * data = [NSMutableArray array];
    for (NSDictionary * field in userData) {
        [data addObject:[[NotificareReactNativeIOSUtils shared] userDataFromDictionary:field]];
    }
    
    [[NotificarePushLib shared] updateUserData:data completionHandler:^(id  _Nullable response, NSError * _Nullable error) {
        if (!error) {
            NSMutableArray * payload = [NSMutableArray array];
            for (NotificareUserData * userData in response) {
                [payload addObject:[[NotificareReactNativeIOSUtils shared] dictionaryFromUserData:userData]];
            }
            resolve(payload);
        } else {
            reject(@"error", [error description], error);
        }
    }];
    
}


RCT_REMAP_METHOD(fetchDoNotDisturb, fetchDoNotDisturbWithResolver:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject) {
    
    [[NotificarePushLib shared] fetchDoNotDisturb:^(id  _Nullable response, NSError * _Nullable error) {
        if (!error) {
            resolve([[NotificareReactNativeIOSUtils shared] dictionaryFromDeviceDnD:response]);
        } else {
            reject(@"error", [error description], error);
        }
    }];
    
}

RCT_REMAP_METHOD(updateDoNotDisturb, deviceDnD:(nonnull NSDictionary *)deviceDnD updateDoNotDisturbWithResolver:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject) {
    
    [[NotificarePushLib shared] updateDoNotDisturb:[[NotificareReactNativeIOSUtils shared] deviceDnDFromDictionary:deviceDnD] completionHandler:^(id  _Nullable response, NSError * _Nullable error) {
        if (!error) {
            resolve([[NotificareReactNativeIOSUtils shared] dictionaryFromDeviceDnD:response]);
        } else {
            reject(@"error", [error description], error);
        }
    }];
    
}

RCT_REMAP_METHOD(clearDoNotDisturb, clearDoNotDisturbWithResolver:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject) {
    
    [[NotificarePushLib shared] clearDoNotDisturb:^(id  _Nullable response, NSError * _Nullable error) {
        if (!error) {
            resolve([[NotificareReactNativeIOSUtils shared] dictionaryFromDeviceDnD:response]);
        } else {
            reject(@"error", [error description], error);
        }
    }];
    
}

RCT_REMAP_METHOD(fetchNotification, notification:(nonnull NSDictionary *)notification fetchNotificationWithResolver:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject) {
    
    [[NotificarePushLib shared] fetchNotification:notification completionHandler:^(id  _Nullable response, NSError * _Nullable error) {
        if (!error) {
            resolve([[NotificareReactNativeIOSUtils shared] dictionaryFromNotification:response]);
        } else {
            reject(@"error", [error description], error);
        }
    }];
    
}

RCT_REMAP_METHOD(clearPrivateNotification, notification:(nonnull NSDictionary *)notification clearPrivateNotificationWithResolver:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject) {
    
    [[NotificarePushLib shared] clearPrivateNotification:[[NotificareReactNativeIOSUtils shared] notificationFromDictionary:notification] completionHandler:^(id  _Nullable response, NSError * _Nullable error) {
        if (!error) {
            resolve([[NotificareReactNativeIOSUtils shared] dictionaryFromNotification:response]);
        } else {
            reject(@"error", [error description], error);
        }
    }];
    
}

RCT_REMAP_METHOD(reply, notification:(nonnull NSDictionary *)notification action:(nonnull NSDictionary *)action data:(nonnull NSDictionary *)data replyWithResolver:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject) {
    
    [[NotificarePushLib shared] reply:[[NotificareReactNativeIOSUtils shared] notificationFromDictionary:notification] forAction:[[NotificareReactNativeIOSUtils shared] actionFromDictionary:action]  andData:data completionHandler:^(id  _Nullable response, NSError * _Nullable error) {
        if (!error) {
            resolve(response);
        } else {
            reject(@"error", [error description], error);
        }
    }];
    
}

RCT_REMAP_METHOD(fetchInbox, fetchInboxWithResolver:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject) {
    
    [[[NotificarePushLib shared] inboxManager] fetchInbox:^(id  _Nullable response, NSError * _Nullable error) {
        if (!error) {
            NSMutableArray * payload = [NSMutableArray array];
            for (NotificareDeviceInbox * inboxItem in response) {
                [payload addObject:[[NotificareReactNativeIOSUtils shared] dictionaryFromDeviceInbox:inboxItem]];
            }
            resolve(payload);
        } else {
            reject(@"error", [error description], error);
        }
    }];
    
}

RCT_EXPORT_METHOD(openInboxItem:(nonnull NSDictionary*)inboxItem) {
    NotificareDeviceInbox * item = [[NotificareReactNativeIOSUtils shared] deviceInboxFromDictionary:inboxItem];
    [[[NotificarePushLib shared] inboxManager] openInboxItem:item completionHandler:^(id  _Nullable response, NSError * _Nullable error) {
        if (!error) {
            UINavigationController *navController = (UINavigationController *)[[[UIApplication sharedApplication] keyWindow] rootViewController];
            [[NotificarePushLib shared] presentInboxItem:item inNavigationController:navController withController:response];
        }
    }];
}

RCT_REMAP_METHOD(removeFromInbox, inboxItem:(nonnull NSDictionary*)inboxItem removeFromInboxWithResolver:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject) {
    
    [[[NotificarePushLib shared] inboxManager] removeFromInbox:[[NotificareReactNativeIOSUtils shared] deviceInboxFromDictionary:inboxItem] completionHandler:^(id  _Nullable response, NSError * _Nullable error) {
        if (!error) {
            resolve([[NotificareReactNativeIOSUtils shared] dictionaryFromDeviceInbox:response]);
        } else {
            reject(@"error", [error description], error);
        }
    }];
    
}

RCT_REMAP_METHOD(markAsRead, inboxItem:(nonnull NSDictionary*)inboxItem markAsReadWithResolver:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject) {
    
    [[[NotificarePushLib shared] inboxManager] markAsRead:[[NotificareReactNativeIOSUtils shared] deviceInboxFromDictionary:inboxItem] completionHandler:^(id  _Nullable response, NSError * _Nullable error) {
        if (!error) {
            resolve([[NotificareReactNativeIOSUtils shared] dictionaryFromDeviceInbox:response]);
        } else {
            reject(@"error", [error description], error);
        }
    }];
    
}

RCT_REMAP_METHOD(clearInbox, clearInboxWithResolver:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject) {
    
    [[[NotificarePushLib shared] inboxManager] clearInbox:^(id  _Nullable response, NSError * _Nullable error) {
        if (!error) {
            resolve(response);
        } else {
            reject(@"error", [error description], error);
        }
    }];
    
}

RCT_REMAP_METHOD(fetchAssets, group:(nonnull NSString*)group fetchAssetsWithResolver:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject) {
    
    [[NotificarePushLib shared] fetchAssets:group completionHandler:^(id  _Nullable response, NSError * _Nullable error) {
        if (!error) {
            NSMutableArray * payload = [NSMutableArray array];
            for (NotificareAsset * asset in response) {
                [payload addObject:[[NotificareReactNativeIOSUtils shared] dictionaryFromAsset:asset]];
            }
            resolve(payload);
        } else {
            reject(@"error", [error description], error);
        }
    }];
    
}

/*


RCT_EXPORT_METHOD(fetchPass:(NSString*)serial callback:(RCTResponseSenderBlock)callback) {
    
    [[NotificarePushLib shared] fetchPass:serial completionHandler:^(NotificarePass *pass) {
        NSMutableDictionary * passObject = [NSMutableDictionary dictionary];
        NSMutableDictionary * p = [NSMutableDictionary dictionary];
        [p setValue:[pass passbook] forKey:@"passbook"];
        [p setValue:[pass serial] forKey:@"serial"];
        [p setObject:[pass data] forKey:@"data"];
        
        NSDateFormatter *dateFormatter=[[NSDateFormatter alloc]init];
        [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
        NSString *dateString = [dateFormatter stringFromDate:[pass date]];
        
        [p setObject:dateString forKey:@"date"];
        [p setObject:[pass limit] forKey:@"limit"];
        [p setObject:[pass redeemHistory] forKey:@"redeemHistory"];
        [p setObject:[pass redeem] forKey:@"redeem"];
        [p setObject:[NSNumber numberWithInt:[pass active]] forKey:@"active"];
        
        if([pass token]){
            [p setObject:[pass token] forKey:@"token"];
        }
        
        [passObject setObject:p forKey:@"pass"];
        
        callback(@[[NSNull null], passObject]);
        
    } errorHandler:^(NSError *error) {
        callback(@[RCTJSErrorFromNSError(error), [NSNull null]]);
    }];
    
}


RCT_EXPORT_METHOD(doCloudHostOperation:(NSString *)http path:(NSString *)path URLParams:(NSDictionary *)params bodyJSON:(NSDictionary *)body callback:(RCTResponseSenderBlock)callback) {
    
    [[NotificarePushLib shared] doCloudHostOperation:http path:path URLParams:params bodyJSON:body successHandler:^(NSDictionary * _Nonnull info) {
        callback(@[[NSNull null], info]);
    } errorHandler:^(NotificareNetworkOperation * _Nonnull operation, NSError * _Nonnull error) {
        callback(@[RCTJSErrorFromNSError(error), [NSNull null]]);
    }];
    
}


RCT_EXPORT_METHOD(fetchProducts:(RCTResponseSenderBlock)callback) {
    
    [[NotificarePushLib shared] fetchProducts:^(NSArray * _Nonnull info) {
        
        NSMutableDictionary * payload = [NSMutableDictionary new];
        NSMutableArray * prods = [NSMutableArray new];
        
        for (NotificareProduct * product in info) {

            [prods addObject:[self dictionaryFromProduct:product]];
        }
        
        [payload setObject:prods forKey:@"products"];
        
        callback(@[[NSNull null], payload]);
        
        
    } errorHandler:^(NSError * _Nonnull error) {
        callback(@[RCTJSErrorFromNSError(error), [NSNull null]]);
    }];
    
}


RCT_EXPORT_METHOD(fetchPurchasedProducts:(RCTResponseSenderBlock)callback) {
    
    [[NotificarePushLib shared] fetchPurchasedProducts:^(NSArray * _Nonnull info) {
        
        NSMutableDictionary * payload = [NSMutableDictionary new];
        NSMutableArray * prods = [NSMutableArray new];
        
        for (NotificareProduct * product in info) {
            [prods addObject:[self dictionaryFromProduct:product]];
        }
        
        [payload setObject:prods forKey:@"products"];
        
        callback(@[[NSNull null], payload]);
        
        
    } errorHandler:^(NSError * _Nonnull error) {
        callback(@[RCTJSErrorFromNSError(error), [NSNull null]]);
    }];
    
}

RCT_EXPORT_METHOD(fetchProduct:(NSString *)productIdentifier callback:(RCTResponseSenderBlock)callback) {
    
    [[NotificarePushLib shared] fetchProduct:productIdentifier completionHandler:^(NotificareProduct * _Nonnull product) {
        callback(@[[NSNull null], [self dictionaryFromProduct:product]]);
    } errorHandler:^(NSError * _Nonnull error) {
        callback(@[RCTJSErrorFromNSError(error), [NSNull null]]);
    }];
    
}


RCT_EXPORT_METHOD(buyProduct:(NSDictionary *)product) {
    
    [[NotificarePushLib shared]  fetchProduct:[product objectForKey:@"identifier"] completionHandler:^(NotificareProduct *product) {
        //
        [[NotificarePushLib shared] buyProduct:product];
        
    } errorHandler:^(NSError *error) {
        //
    }];

}


RCT_EXPORT_METHOD(resetPassword:(NSString *)password token:(NSString *)token callback:(RCTResponseSenderBlock)callback) {
    
    [[NotificarePushLib shared] resetPassword:password withToken:token completionHandler:^(NSDictionary * _Nonnull info) {
        callback(@[[NSNull null], info]);
    } errorHandler:^(NSError * _Nonnull error) {
        callback(@[RCTJSErrorFromNSError(error), [NSNull null]]);
    }];
    
}

RCT_EXPORT_METHOD(sendPassword:(NSString *)email callback:(RCTResponseSenderBlock)callback) {
    
    [[NotificarePushLib shared] sendPassword:email completionHandler:^(NSDictionary * _Nonnull info) {
        callback(@[[NSNull null], info]);
    } errorHandler:^(NSError * _Nonnull error) {
        callback(@[RCTJSErrorFromNSError(error), [NSNull null]]);
    }];
    
}


RCT_EXPORT_METHOD(createAccount:(NSString *)email name:(NSString *)name password:(NSString *)password callback:(RCTResponseSenderBlock)callback) {
    
    [[NotificarePushLib shared] createAccount:email withName:name andPassword:password completionHandler:^(NSDictionary * _Nonnull info) {
        callback(@[[NSNull null], info]);
    } errorHandler:^(NSError * _Nonnull error) {
        callback(@[RCTJSErrorFromNSError(error), [NSNull null]]);
    }];
    
}


RCT_EXPORT_METHOD(login:(NSString *)email password:(NSString *)password callback:(RCTResponseSenderBlock)callback) {
    
    [[NotificarePushLib shared] loginWithUsername:email andPassword:password completionHandler:^(NSDictionary * _Nonnull info) {
        callback(@[[NSNull null], info]);
    } errorHandler:^(NSError * _Nonnull error) {
        callback(@[RCTJSErrorFromNSError(error), [NSNull null]]);
    }];
    
}


RCT_EXPORT_METHOD(logout){
    
    [[NotificarePushLib shared] logoutAccount];
    
}


RCT_EXPORT_METHOD(fetchAccountDetails:(RCTResponseSenderBlock)callback) {
    
    [[NotificarePushLib shared] fetchAccountDetails:^(NSDictionary * _Nonnull info) {
        callback(@[[NSNull null], info]);
    } errorHandler:^(NSError * _Nonnull error) {
        callback(@[RCTJSErrorFromNSError(error), [NSNull null]]);
    }];
    
}


RCT_EXPORT_METHOD(fetchUserPreferences:(RCTResponseSenderBlock)callback) {
    
    NSMutableArray * prefs = [NSMutableArray array];
    
    [[NotificarePushLib shared] fetchUserPreferences:^(NSArray *result) {

        NSMutableDictionary * trans = [NSMutableDictionary dictionary];
        
        for (NotificareUserPreference * preference in result){
            
            NSMutableDictionary * pref = [NSMutableDictionary dictionary];
            
            [pref setObject:[preference preferenceId] forKey:@"preferenceId"];
            [pref setObject:[preference preferenceLabel] forKey:@"label"];
            [pref setObject:[preference preferenceType] forKey:@"type"];
            
            NSMutableArray * segments = [NSMutableArray array];
            
            for (NotificareSegment * seg in [preference preferenceOptions]) {
                NSMutableDictionary * s = [NSMutableDictionary dictionary];
                [s setObject:[seg segmentId] forKey:@"segmentId"];
                [s setObject:[seg segmentLabel] forKey:@"label"];
                [s setObject:[NSNumber numberWithBool:[seg selected]] forKey:@"selected"];
                [segments addObject:s];
            }
            
            [pref setObject:segments forKey:@"segments"];
            [prefs addObject:pref];
        }
        
        [trans setObject:prefs forKey:@"userPreferences"];
        
        callback(@[[NSNull null], trans]);
        
    } errorHandler:^(NSError * _Nonnull error) {
        callback(@[RCTJSErrorFromNSError(error), [NSNull null]]);
    }];
    
}

RCT_EXPORT_METHOD(addSegmentToPreference:(NSDictionary*)segment preference:(NSDictionary*)preference callback:(RCTResponseSenderBlock)callback) {
    
    NotificareSegment * s = [NotificareSegment new];
    [s setSegmentId:[segment objectForKey:@"segmentId"]];
    
    NotificareUserPreference * p = [NotificareUserPreference new];
    [p setPreferenceId:[preference objectForKey:@"preferenceId"]];
    
    [[NotificarePushLib shared] addSegment:s toPreference:p completionHandler:^(NSDictionary * result) {
        
        callback(@[[NSNull null], result]);
        
    } errorHandler:^(NSError * _Nonnull error) {
        callback(@[RCTJSErrorFromNSError(error), [NSNull null]]);
    }];
    
}


RCT_EXPORT_METHOD(removeSegmentFromPreference:(NSDictionary*)segment preference:(NSDictionary*)preference callback:(RCTResponseSenderBlock)callback) {
    
    NotificareSegment * s = [NotificareSegment new];
    [s setSegmentId:[segment objectForKey:@"segmentId"]];
    
    NotificareUserPreference * p = [NotificareUserPreference new];
    [p setPreferenceId:[preference objectForKey:@"preferenceId"]];
    
    [[NotificarePushLib shared] removeSegment:s fromPreference:p completionHandler:^(NSDictionary * result) {
        
        callback(@[[NSNull null], result]);
        
    } errorHandler:^(NSError * _Nonnull error) {
        callback(@[RCTJSErrorFromNSError(error), [NSNull null]]);
    }];
    
}

RCT_EXPORT_METHOD(generateAccessToken:(RCTResponseSenderBlock)callback) {
    
    [[NotificarePushLib shared] generateAccessToken:^(NSDictionary * result) {
        
        callback(@[[NSNull null], result]);
        
    } errorHandler:^(NSError * _Nonnull error) {
        callback(@[RCTJSErrorFromNSError(error), [NSNull null]]);
    }];
    
}

RCT_EXPORT_METHOD(changePassword:(NSString*)password callback:(RCTResponseSenderBlock)callback) {
    
    [[NotificarePushLib shared] changePassword:password completionHandler:^(NSDictionary * _Nonnull info) {
        
        callback(@[[NSNull null], info]);
        
    } errorHandler:^(NSError * _Nonnull error) {
        callback(@[RCTJSErrorFromNSError(error), [NSNull null]]);
    }];
    
}


RCT_EXPORT_METHOD(logOpenNotification:(NSDictionary*)notification) {
    
    [[NotificarePushLib shared] logOpenNotification:notification];
    
}

RCT_EXPORT_METHOD(logInfluencedOpenNotification:(NSDictionary*)notification) {
    
    [[NotificarePushLib shared] logInfluencedOpenNotification:notification];
    
}



RCT_EXPORT_METHOD(logCustomEvent:(NSString *)name andData:(NSDictionary *)data  callback:(RCTResponseSenderBlock)callback) {
    
    [[NotificarePushLib shared] logCustomEvent:name withData:data completionHandler:^(NSDictionary * _Nonnull info) {
        callback(@[[NSNull null], info]);
    } errorHandler:^(NSError * _Nonnull error) {
        callback(@[RCTJSErrorFromNSError(error), [NSNull null]]);
    }];
    
}
*/
@end

/**
 *
 * Helper class to handle NotificarePushLib delegates
 *
 */
@implementation PushHandler

-(void)notificarePushLib:(NotificarePushLib *)library onReady:(nonnull NotificareApplication *)application {
    
    [[NotificareReactNativeIOS getInstance] dispatchEvent:@"notificare:onReady" body:[[NotificareReactNativeIOSUtils shared] dictionaryFromApplication:application]];
  
}

//-(void)notificarePushLib:(NotificarePushLib *)library willHandleNotification:(UNNotification *)notification{
//
//  [[NotificareReactNativeIOS getInstance] dispatchEvent:@"notificationOpened" body:notification.request.content.userInfo];
//
//}
//
//- (void)notificarePushLib:(NotificarePushLib *)library didReceiveSystemPush:(nonnull NSDictionary *)info{
//  [[NotificareReactNativeIOS getInstance] dispatchEvent:@"systemPush" body:info];
//}
//
//-(void)notificarePushLib:(NotificarePushLib *)library didUpdateBadge:(int)badge{
//
//  NSMutableDictionary * info = [NSMutableDictionary new];
//  [info setObject:[NSNumber numberWithInt:badge] forKey:@"badge"];
//  [[NotificareReactNativeIOS getInstance] dispatchEvent:@"badge" body:info];
//
//}
//
//
//- (void)notificarePushLib:(NotificarePushLib *)library willOpenNotification:(NotificareNotification *)notification{
//
//    [[NotificareReactNativeIOS getInstance] dispatchEvent:@"willOpenNotification" body:[self dictionaryFromNotification:notification]];
//
//}
//
//- (void)notificarePushLib:(NotificarePushLib *)library didOpenNotification:(NotificareNotification *)notification{
//
//    [[NotificareReactNativeIOS getInstance] dispatchEvent:@"didOpenNotification" body:[self dictionaryFromNotification:notification]];
//
//}
//
//- (void)notificarePushLib:(NotificarePushLib *)library didClickURL:(NSURL *)url inNotification:(NotificareNotification *)notification{
//
//    NSMutableDictionary * payload = [NSMutableDictionary dictionaryWithDictionary:[self dictionaryFromNotification:notification]];
//    [payload setObject:[url absoluteString] forKey:@"url"];
//
//    [[NotificareReactNativeIOS getInstance] dispatchEvent:@"didClickURL" body:payload];
//}
//
//- (void)notificarePushLib:(NotificarePushLib *)library didCloseNotification:(NotificareNotification *)notification{
//
//    [[NotificareReactNativeIOS getInstance] dispatchEvent:@"didCloseNotification" body:[self dictionaryFromNotification:notification]];
//
//}
//
//- (void)notificarePushLib:(NotificarePushLib *)library didFailToOpenNotification:(NotificareNotification *)notification{
//
//    [[NotificareReactNativeIOS getInstance] dispatchEvent:@"didFailToOpenNotification" body:[self dictionaryFromNotification:notification]];
//
//}
//
//
//- (void)notificarePushLib:(NotificarePushLib *)library willExecuteAction:(NotificareNotification *)notification{
//
//    [[NotificareReactNativeIOS getInstance] dispatchEvent:@"willExecuteAction" body:[self dictionaryFromNotification:notification]];
//}
//
//- (void)notificarePushLib:(NotificarePushLib *)library didExecuteAction:(NSDictionary *)info{
//
//}
//
//
//-(void)notificarePushLib:(NotificarePushLib *)library shouldPerformSelectorWithURL:(NSURL *)url{
//
//    NSMutableDictionary * payload = [NSMutableDictionary new];
//    [payload setObject:[url absoluteString] forKey:@"url"];
//
//    [[NotificareReactNativeIOS getInstance] dispatchEvent:@"shouldPerformSelectorWithURL" body:payload];
//}
//
//- (void)notificarePushLib:(NotificarePushLib *)library didNotExecuteAction:(NSDictionary *)info{
//
//    [[NotificareReactNativeIOS getInstance] dispatchEvent:@"didNotExecuteAction" body:info];
//
//}
//
//- (void)notificarePushLib:(NotificarePushLib *)library didFailToExecuteAction:(NSError *)error{
//
//    [[NotificareReactNativeIOS getInstance] dispatchEvent:@"didFailToExecuteAction" body:@{@"error" : [error localizedDescription]}];
//
//}
//
//
//#pragma Notificare Location delegates
//- (void)notificarePushLib:(NotificarePushLib *)library didReceiveLocationServiceAuthorizationStatus:(NSDictionary *)status{
//
//    [[NotificareReactNativeIOS getInstance] dispatchEvent:@"didReceiveLocationServiceAuthorizationStatus" body:status];
//
//}
//
//- (void)notificarePushLib:(NotificarePushLib *)library didFailToStartLocationServiceWithError:(NSError *)error{
//
//    [[NotificareReactNativeIOS getInstance] dispatchEvent:@"didFailToStartLocationServiceWithError" body:@{@"error" : [error localizedDescription]}];
//
//}
//
//- (void)notificarePushLib:(NotificarePushLib *)library didUpdateLocations:(NSArray *)locations{
//
//    CLLocation * lastLocation = (CLLocation *)[locations lastObject];
//    NSMutableDictionary * location = [NSMutableDictionary dictionary];
//    [location setValue:[NSNumber numberWithFloat:[lastLocation coordinate].latitude] forKey:@"latitude"];
//    [location setValue:[NSNumber numberWithFloat:[lastLocation coordinate].longitude] forKey:@"longitude"];
//    [[NotificareReactNativeIOS getInstance] dispatchEvent:@"didUpdateLocations" body:location];
//
//}
//
//- (void)notificarePushLib:(NotificarePushLib *)library monitoringDidFailForRegion:(CLRegion *)region withError:(NSError *)error{
//
//    NSMutableDictionary * payload = [NSMutableDictionary dictionary];
//    [payload setObject:[region identifier] forKey:@"region"];
//    [payload setObject:[error localizedDescription] forKey:@"error"];
//
//    [[NotificareReactNativeIOS getInstance] dispatchEvent:@"monitoringDidFailForRegion" body:payload];
//
//}
//
//
//- (void)notificarePushLib:(NotificarePushLib *)library didDetermineState:(CLRegionState)state forRegion:(CLRegion *)region{
//
//    NSMutableDictionary * payload = [NSMutableDictionary dictionary];
//    [payload setObject:[region identifier] forKey:@"region"];
//    [payload setObject:[NSNumber numberWithInt:state] forKey:@"state"];
//
//    [[NotificareReactNativeIOS getInstance] dispatchEvent:@"didDetermineState" body:payload];
//
//}
//
//
//- (void)notificarePushLib:(NotificarePushLib *)library didEnterRegion:(CLRegion *)region{
//
//    NSMutableDictionary * payload = [NSMutableDictionary dictionary];
//    [payload setObject:[region identifier] forKey:@"region"];;
//
//    [[NotificareReactNativeIOS getInstance] dispatchEvent:@"didEnterRegion" body:payload];
//
//}
//
//
//
//- (void)notificarePushLib:(NotificarePushLib *)library didExitRegion:(CLRegion *)region{
//
//    NSMutableDictionary * payload = [NSMutableDictionary dictionary];
//    [payload setObject:[region identifier] forKey:@"region"];;
//
//    [[NotificareReactNativeIOS getInstance] dispatchEvent:@"didExitRegion" body:payload];
//
//}
//
//
//- (void)notificarePushLib:(NotificarePushLib *)library didStartMonitoringForRegion:(CLRegion *)region{
//
//    NSMutableDictionary * payload = [NSMutableDictionary dictionary];
//    [payload setObject:[region identifier] forKey:@"region"];;
//
//    [[NotificareReactNativeIOS getInstance] dispatchEvent:@"didStartMonitoringForRegion" body:payload];
//
//}
//
//
//- (void)notificarePushLib:(NotificarePushLib *)library rangingBeaconsDidFailForRegion:(CLBeaconRegion *)region withError:(NSError *)error{
//
//    NSMutableDictionary * payload = [NSMutableDictionary dictionary];
//    [payload setObject:[region identifier] forKey:@"region"];
//    [payload setObject:[error localizedDescription] forKey:@"error"];
//
//    [[NotificareReactNativeIOS getInstance] dispatchEvent:@"rangingBeaconsDidFailForRegion" body:payload];
//
//}
//
//- (void)notificarePushLib:(NotificarePushLib *)library didRangeBeacons:(NSArray *)beacons inRegion:(CLBeaconRegion *)region{
//
//    NSMutableDictionary * payload = [NSMutableDictionary dictionary];
//    NSMutableArray * theBeacons = [NSMutableArray array];
//
//    [payload setObject:[region identifier] forKey:@"region"];
//
//    for (NotificareBeacon * beacon in beacons) {
//        NSMutableDictionary * b = [NSMutableDictionary dictionary];
//        [b setObject:[[beacon beaconUUID] UUIDString] forKey:@"uuid"];
//        [b setObject:[beacon major] forKey:@"major"];
//        [b setObject:[beacon minor] forKey:@"minor"];
//        [b setObject:[beacon notification] forKey:@"notification"];
//        [b setObject:[NSNumber numberWithInt:[[beacon beacon] proximity]] forKey:@"proximity"];
//        [theBeacons addObject:b];
//    }
//
//    [payload setObject:theBeacons forKey:@"beacons"];
//
//    [[NotificareReactNativeIOS getInstance] dispatchEvent:@"didRangeBeacons" body:payload];
//
//}
//
//
//#pragma Notificare In-App Purchases
//
//- (void)notificarePushLib:(NotificarePushLib *)library didLoadStore:(NSArray *)products{
//
//    NSMutableDictionary * payload = [NSMutableDictionary dictionary];
//    NSMutableArray * prods = [NSMutableArray new];
//
//    for (NotificareProduct * product in products) {
//        [prods addObject:[self dictionaryFromProduct:product]];
//    }
//
//    [payload setObject:prods forKey:@"products"];
//
//    [[NotificareReactNativeIOS getInstance] dispatchEvent:@"didLoadStore" body:payload];
//
//}
//
//
//- (void)notificarePushLib:(NotificarePushLib *)library didFailToLoadStore:(NSError *)error{
//
//    [[NotificareReactNativeIOS getInstance] dispatchEvent:@"didFailToLoadStore" body:@{@"products": @[]}];
//
//}
//
//- (void)notificarePushLib:(NotificarePushLib *)library didFailProductTransaction:(SKPaymentTransaction *)transaction withError:(NSError *)error{
//
//    NSMutableDictionary * payload = [NSMutableDictionary dictionary];
//    [payload setObject:[transaction transactionIdentifier] forKey:@"transaction"];
//    [payload setObject:[error localizedDescription] forKey:@"error"];
//
//    [[NotificareReactNativeIOS getInstance] dispatchEvent:@"didFailProductTransaction" body:payload];
//}
//
//
//- (void)notificarePushLib:(NotificarePushLib *)library didCompleteProductTransaction:(SKPaymentTransaction *)transaction{
//
//    NSMutableDictionary * payload = [NSMutableDictionary dictionary];
//    [payload setObject:[transaction transactionIdentifier] forKey:@"transaction"];
//
//    [[NotificareReactNativeIOS getInstance] dispatchEvent:@"didCompleteProductTransaction" body:payload];
//}
//
//
//- (void)notificarePushLib:(NotificarePushLib *)library didRestoreProductTransaction:(SKPaymentTransaction *)transaction{
//
//    NSMutableDictionary * payload = [NSMutableDictionary dictionary];
//    [payload setObject:[transaction transactionIdentifier] forKey:@"transaction"];
//
//    [[NotificareReactNativeIOS getInstance] dispatchEvent:@"didRestoreProductTransaction" body:payload];
//
//}
//
//
//- (void)notificarePushLib:(NotificarePushLib *)library didStartDownloadContent:(SKPaymentTransaction *)transaction{
//
//    NSMutableDictionary * payload = [NSMutableDictionary dictionary];
//    [payload setObject:[transaction transactionIdentifier] forKey:@"transaction"];
//
//    [[NotificareReactNativeIOS getInstance] dispatchEvent:@"didStartDownloadContent" body:payload];
//
//}
//
//
//- (void)notificarePushLib:(NotificarePushLib *)library didPauseDownloadContent:(SKDownload *)download{
//
//    [[NotificareReactNativeIOS getInstance] dispatchEvent:@"didPauseDownloadContent" body:[self dictionaryFromSKDownload:download]];
//
//}
//
//
//- (void)notificarePushLib:(NotificarePushLib *)library didCancelDownloadContent:(SKDownload *)download{
//
//    [[NotificareReactNativeIOS getInstance] dispatchEvent:@"didCancelDownloadContent" body:[self dictionaryFromSKDownload:download]];
//
//}
//
//
//- (void)notificarePushLib:(NotificarePushLib *)library didReceiveProgressDownloadContent:(SKDownload *)download{
//
//    [[NotificareReactNativeIOS getInstance] dispatchEvent:@"didReceiveProgressDownloadContent" body:[self dictionaryFromSKDownload:download]];
//}
//
//
//- (void)notificarePushLib:(NotificarePushLib *)library didFailDownloadContent:(SKDownload *)download{
//
//    [[NotificareReactNativeIOS getInstance] dispatchEvent:@"didFailDownloadContent" body:[self dictionaryFromSKDownload:download]];
//}
//
//
//- (void)notificarePushLib:(NotificarePushLib *)library didFinishDownloadContent:(SKDownload *)download{
//
//    [[NotificareReactNativeIOS getInstance] dispatchEvent:@"didFinishDownloadContent" body:[self dictionaryFromSKDownload:download]];
//}
//
//
//#pragma Notificare OAuth2 delegates
//
//- (void)notificarePushLib:(NotificarePushLib *)library didChangeAccountNotification:(NSDictionary *)info{
//    [[NotificareReactNativeIOS getInstance] dispatchEvent:@"didChangeAccountNotification" body:info];
//}
//
//- (void)notificarePushLib:(NotificarePushLib *)library didFailToRequestAccessNotification:(NSError *)error{
//
//    [[NotificareReactNativeIOS getInstance] dispatchEvent:@"didFailToRequestAccessNotification" body:RCTJSErrorFromNSError(error)];
//}
//
//
//- (void)notificarePushLib:(NotificarePushLib *)library didReceiveActivationToken:(NSString *)token{
//
//    [[NotificarePushLib shared] validateAccount:token completionHandler:^(NSDictionary *info) {
//
//        [[NotificareReactNativeIOS getInstance] dispatchEvent:@"didValidateAccount" body:info];
//
//    } errorHandler:^(NSError *error) {
//
//        [[NotificareReactNativeIOS getInstance] dispatchEvent:@"didFailToValidateAccount" body:RCTJSErrorFromNSError(error)];
//
//    }];
//
//}
//
//- (void)notificarePushLib:(NotificarePushLib *)library didReceiveResetPasswordToken:(NSString *)token{
//
//    [[NotificareReactNativeIOS getInstance] dispatchEvent:@"didReceiveResetPasswordToken" body:@{@"token": token}];
//}
//

@end
