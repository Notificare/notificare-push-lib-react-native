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
#import "../Libraries/NotificarePushLib/UIImage+FromBundle.h"

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
    [[NotificareReactNativeIOS getInstance] dispatchEvent:@"urlOpened" body:payload];
}

- (NSArray<NSString*> *)supportedEvents {
    return @[
             @"ready",
             @"urlOpened",
             @"deviceRegistered",
             @"notificationSettingsChanged",
             @"launchUrlReceived",
             @"inboxLoaded",
             @"badgeUpdated",
             @"remoteNotificationReceivedInBackground",
             @"remoteNotificationReceivedInForeground",
             @"systemNotificationReceivedInBackground",
             @"systemNotificationReceivedInForeground",
             @"unknownNotificationReceived",
             @"unknownActionForNotificationReceived",
             @"notificationWillOpen",
             @"notificationOpened",
             @"notificationClosed",
             @"notificationFailedToOpen",
             @"urlClickedInNotification",
             @"actionWillExecute",
             @"actionExecuted",
             @"shouldPerformSelectorWithUrl",
             @"actionNotExecuted",
             @"actionFailedToExecute",
             @"shouldOpenSettings",
             @"locationServiceFailedToStart",
             @"locationsUpdated",
             @"monitoringForRegionFailed",
             @"monitoringForRegionStarted",
             @"stateForRegionChanged",
             @"regionEntered",
             @"regionExited",
             @"rangingBeaconsFailed",
             @"beaconsInRangeForRegion"
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

- (void)dispatchEvent:(NSString *)event body:(id)notification {
  [self sendEventWithName:event body:notification];
}

-(void)close{
    [[[[UIApplication sharedApplication] keyWindow] rootViewController] dismissViewControllerAnimated:YES completion:^{
        
    }];
}

-(UINavigationController*)navigationControllerForViewControllers:(id)object{
    UINavigationController *navController = [UINavigationController new];
    [[(UIViewController *)object navigationItem] setLeftBarButtonItem:[[UIBarButtonItem alloc] initWithImage:[UIImage imageFromBundle:@"closeIcon"] style:UIBarButtonItemStylePlain target:self action:@selector(close)]];
    return navController;
}

-(UINavigationController*)navigationControllerForRootViewController{
    UINavigationController * navController = (UINavigationController*)[[[UIApplication sharedApplication] keyWindow] rootViewController];
    return navController;
}

-(BOOL)isViewController:(id)controller{
    BOOL result = YES;
    if ([[controller class] isEqual:[UIAlertController class]] ||
        [[controller class] isEqual:[SKStoreProductViewController class]] ||
        [[controller class] isEqual:[NSObject class]] ||
        controller == nil) {
        result = NO;
    }
    return result;
}

RCT_EXPORT_MODULE()

RCT_EXPORT_METHOD(initializeWithKeyAndSecret:(NSString * _Nullable)key secret:(NSString * _Nullable)secret){
    pushHandler = [[PushHandler alloc] init];
    [[NotificarePushLib shared] initializeWithKey:key andSecret:secret];
    [[NotificarePushLib shared] setDelegate:pushHandler];
    NSUserDefaults * defaults = [NSUserDefaults standardUserDefaults];
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

RCT_EXPORT_METHOD(launch){
    [[NotificarePushLib shared] launch];
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

RCT_REMAP_METHOD(isLocationServicesEnabled, isLocationServicesEnabledWithResolver:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject) {
    resolve(@([[NotificarePushLib shared] locationServicesEnabled]));
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

RCT_EXPORT_METHOD(presentNotification:(nonnull NSDictionary*)notification) {
    
    NotificareNotification * item = [[NotificareReactNativeIOSUtils shared] notificationFromDictionary:notification];
    id controller = [[NotificarePushLib shared] controllerForNotification:item];
    if ([self isViewController:controller]) {
        UINavigationController *navController = [self navigationControllerForViewControllers:controller];
        [[[[UIApplication sharedApplication] keyWindow] rootViewController] presentViewController:navController animated:NO completion:^{
            [[NotificarePushLib shared] presentNotification:item inNavigationController:navController withController:controller];
        }];
    } else {
        [[NotificarePushLib shared] presentNotification:item inNavigationController:[self navigationControllerForRootViewController] withController:controller];
    }
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

RCT_EXPORT_METHOD(presentInboxItem:(nonnull NSDictionary*)inboxItem) {
    NotificareDeviceInbox * item = [[NotificareReactNativeIOSUtils shared] deviceInboxFromDictionary:inboxItem];
    [[[NotificarePushLib shared] inboxManager] openInboxItem:item completionHandler:^(id  _Nullable response, NSError * _Nullable error) {
        if (!error) {
            if ([self isViewController:response]) {
                UINavigationController *navController = [self navigationControllerForViewControllers:response];
                [[[[UIApplication sharedApplication] keyWindow] rootViewController] presentViewController:navController animated:NO completion:^{
                    [[NotificarePushLib shared] presentInboxItem:item inNavigationController:navController withController:response];
                }];
            } else {
                [[NotificarePushLib shared] presentInboxItem:item inNavigationController:[self navigationControllerForRootViewController] withController:response];
            }
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


RCT_REMAP_METHOD(fetchPassWithSerial, serial:(nonnull NSString*)serial fetchPassWithSerialWithResolver:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject) {
    
    [[NotificarePushLib shared] fetchPassWithSerial:serial completionHandler:^(id  _Nullable response, NSError * _Nullable error) {
        if (!error) {
            resolve([[NotificareReactNativeIOSUtils shared] dictionaryFromPass:response]);
        } else {
            reject(@"error", [error description], error);
        }
    }];
    
}

RCT_REMAP_METHOD(fetchPassWithBarcode, barcode:(nonnull NSString*)barcode fetchPassWithBarcodeWithResolver:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject) {
    
    [[NotificarePushLib shared] fetchPassWithBarcode:barcode completionHandler:^(id  _Nullable response, NSError * _Nullable error) {
        if (!error) {
            resolve([[NotificareReactNativeIOSUtils shared] dictionaryFromPass:response]);
        } else {
            reject(@"error", [error description], error);
        }
    }];
    
}

RCT_REMAP_METHOD(fetchProducts, fetchProductsWithResolver:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject) {
    
    [[NotificarePushLib shared] fetchProducts:^(id  _Nullable response, NSError * _Nullable error) {
        if (!error) {
            NSMutableArray * payload = [NSMutableArray array];
            for (NotificareProduct * product in response) {
                [payload addObject:[[NotificareReactNativeIOSUtils shared] dictionaryFromProduct:product]];
            }
            resolve(payload);
        } else {
            reject(@"error", [error description], error);
        }
    }];
    
}

RCT_REMAP_METHOD(fetchPurchasedProducts, fetchPurchasedProductsWithResolver:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject) {
    
    [[NotificarePushLib shared] fetchPurchasedProducts:^(id  _Nullable response, NSError * _Nullable error) {
        if (!error) {
            NSMutableArray * payload = [NSMutableArray array];
            for (NotificareProduct * product in response) {
                [payload addObject:[[NotificareReactNativeIOSUtils shared] dictionaryFromProduct:product]];
            }
            resolve(payload);
        } else {
            reject(@"error", [error description], error);
        }
    }];
    
}

RCT_REMAP_METHOD(fetchProduct, product:(nonnull NSDictionary*)product fetchProductWithResolver:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject) {
    
    [[NotificarePushLib shared] fetchProduct:[product objectForKey:@"productIdentifier"] completionHandler:^(id  _Nullable response, NSError * _Nullable error) {
        if (!error) {
            resolve([[NotificareReactNativeIOSUtils shared] dictionaryFromProduct:response]);
        } else {
            reject(@"error", [error description], error);
        }
    }];
    
}

RCT_EXPORT_METHOD(buyProduct:(nonnull NSDictionary*)product) {
    
    [[NotificarePushLib shared] fetchProduct:[product objectForKey:@"productIdentifier"] completionHandler:^(id  _Nullable response, NSError * _Nullable error) {
        if (!error) {
            [[NotificarePushLib shared] buyProduct:response];
        }
    }];
    
}

RCT_REMAP_METHOD(logCustomEvent, name:(nonnull NSString*)name data:(NSDictionary* _Nullable)data logCustomEventWithResolver:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject) {
    
    [[NotificarePushLib shared] logCustomEvent:name withData:data completionHandler:^(id  _Nullable response, NSError * _Nullable error) {
        if (!error) {
            resolve(response);
        } else {
            reject(@"error", [error description], error);
        }
    }];
    
}

RCT_REMAP_METHOD(logOpenNotification, notification:(NSDictionary* _Nullable)notification logOpenNotificationWithResolver:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject) {
    
    NSMutableDictionary * eventData = [NSMutableDictionary dictionary];
    [eventData setObject:[notification objectForKey:@"id"] forKey:@"notification"];
    
    [[NotificarePushLib shared] logEvent:kNotificareEventNotificationOpen withData:eventData completionHandler:^(id  _Nullable response, NSError * _Nullable error) {
        if (!error) {
            resolve(response);
        } else {
            reject(@"error", [error description], error);
        }
    }];
    
}

RCT_REMAP_METHOD(logInfluencedNotification, notification:(NSDictionary* _Nullable)notification logInfluencedNotificationWithResolver:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject) {
    
    NSMutableDictionary * eventData = [NSMutableDictionary dictionary];
    [eventData setObject:[notification objectForKey:@"id"] forKey:@"notification"];
    
    [[NotificarePushLib shared] logEvent:kNotificareEventNotificationInfluenced withData:eventData completionHandler:^(id  _Nullable response, NSError * _Nullable error) {
        if (!error) {
            resolve(response);
        } else {
            reject(@"error", [error description], error);
        }
    }];
    
}

RCT_REMAP_METHOD(logReceiveNotification, notification:(NSDictionary* _Nullable)notification logReceiveNotificationWithResolver:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject) {
    
    NSMutableDictionary * eventData = [NSMutableDictionary dictionary];
    [eventData setObject:[notification objectForKey:@"id"] forKey:@"notification"];
    
    [[NotificarePushLib shared] logEvent:kNotificareEventNotificationReceive withData:eventData completionHandler:^(id  _Nullable response, NSError * _Nullable error) {
        if (!error) {
            resolve(response);
        } else {
            reject(@"error", [error description], error);
        }
    }];
    
}

RCT_REMAP_METHOD(doPushHostOperation, verb:(nonnull NSString*)verb path:(nonnull NSString*)path params:(NSDictionary<NSString *,NSString *> * _Nullable)params body:(NSDictionary* _Nullable)body doPushHostOperationWithResolver:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject) {
    
    [[NotificarePushLib shared] doPushHostOperation:verb path:path URLParams:params bodyJSON:body completionHandler:^(id  _Nullable response, NSError * _Nullable error) {
        if (!error) {
            resolve(response);
        } else {
            reject(@"error", [error description], error);
        }
    }];
    
}

RCT_REMAP_METHOD(doCloudHostOperation, verb:(nonnull NSString*)verb path:(nonnull NSString*)path params:(NSDictionary<NSString *,NSString *> * _Nullable)params headers:(NSDictionary<NSString *,NSString *> * _Nullable)headers body:(NSDictionary* _Nullable)body doCloudHostOperationWithResolver:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject) {
    
    [[NotificarePushLib shared] doCloudHostOperation:verb path:path URLParams:params customHeaders:headers bodyJSON:body completionHandler:^(id  _Nullable response, NSError * _Nullable error) {
        if (!error) {
            resolve(response);
        } else {
            reject(@"error", [error description], error);
        }
    }];
    
}

RCT_REMAP_METHOD(createAccount, email:(nonnull NSString*)email name:(nonnull NSString*)name password:(nonnull NSString*)password createAccountWithResolver:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject) {
    
    [[[NotificarePushLib shared] authManager] createAccount:email withName:name andPassword:password completionHandler:^(id  _Nullable response, NSError * _Nullable error) {
        if (!error) {
            resolve(response);
        } else {
            reject(@"error", [error description], error);
        }
    }];
    
}

RCT_REMAP_METHOD(resetPassword, password:(nonnull NSString*)password token:(nonnull NSString*)token resetPasswordWithResolver:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject) {
    
    [[[NotificarePushLib shared] authManager] resetPassword:password withToken:token completionHandler:^(id  _Nullable response, NSError * _Nullable error) {
        if (!error) {
            resolve(response);
        } else {
            reject(@"error", [error description], error);
        }
    }];
    
}

RCT_REMAP_METHOD(sendPassword, email:(nonnull NSString*)email sendPasswordWithResolver:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject) {
    
    [[[NotificarePushLib shared] authManager] sendPassword:email completionHandler:^(id  _Nullable response, NSError * _Nullable error) {
        if (!error) {
            resolve(response);
        } else {
            reject(@"error", [error description], error);
        }
    }];
    
}

RCT_REMAP_METHOD(login, email:(nonnull NSString*)email password:(nonnull NSString*)password loginWithResolver:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject) {
    
    [[[NotificarePushLib shared] authManager] loginWithUsername:email andPassword:password completionHandler:^(id  _Nullable response, NSError * _Nullable error) {
        if (!error) {
            resolve(response);
        } else {
            reject(@"error", [error description], error);
        }
    }];
    
}

RCT_EXPORT_METHOD(logout){
    [[[NotificarePushLib shared] authManager] logoutAccount];
}

RCT_REMAP_METHOD(isLoggedIn, isLoggedInResolver:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject) {
    resolve(@([[[NotificarePushLib shared] authManager] isLoggedIn]));
}

RCT_REMAP_METHOD(generateAccessToken, generateAccessTokenWithResolver:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject) {
    
    [[[NotificarePushLib shared] authManager] generateAccessToken:^(id  _Nullable response, NSError * _Nullable error) {
        if (!error) {
            resolve(response);
        } else {
            reject(@"error", [error description], error);
        }
    }];
    
}

RCT_REMAP_METHOD(changePassword, password:(nonnull NSString*)password changePasswordWithResolver:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject) {
    
    [[[NotificarePushLib shared] authManager] changePassword:password completionHandler:^(id  _Nullable response, NSError * _Nullable error) {
        if (!error) {
            resolve(response);
        } else {
            reject(@"error", [error description], error);
        }
    }];
    
}


RCT_REMAP_METHOD(fetchAccountDetails, fetchAccountDetailsWithResolver:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject) {
    
    [[[NotificarePushLib shared] authManager] fetchAccountDetails:^(id  _Nullable response, NSError * _Nullable error) {
        if (!error) {
            resolve([[NotificareReactNativeIOSUtils shared] dictionaryFromUser:response]);
        } else {
            reject(@"error", [error description], error);
        }
    }];
    
}

RCT_REMAP_METHOD(fetchUserPreferences, fetchUserPreferencesWithResolver:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject) {
    
    [[[NotificarePushLib shared] authManager] fetchUserPreferences:^(id  _Nullable response, NSError * _Nullable error) {
        if (!error) {
            NSMutableArray * payload = [NSMutableArray array];
            for (NotificareUserPreference * preference in response) {
                [payload addObject:[[NotificareReactNativeIOSUtils shared] dictionaryFromUserPreference:preference]];
            }
            resolve(payload);
        } else {
            reject(@"error", [error description], error);
        }
    }];
    
}

RCT_REMAP_METHOD(addSegmentToUserPreference, segment:(nonnull NSDictionary*)segment userPreference:(nonnull NSDictionary*)userPreference addSegmentToUserPreferenceWithResolver:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject) {
    
    [[[NotificarePushLib shared] authManager] addSegment:[[NotificareReactNativeIOSUtils shared] segmentFromDictionary:segment] toPreference:[[NotificareReactNativeIOSUtils shared] userPreferenceFromDictionary:userPreference] completionHandler:^(id  _Nullable response, NSError * _Nullable error) {
        if (!error) {
            resolve(response);
        } else {
            reject(@"error", [error description], error);
        }
    }];
    
}

RCT_REMAP_METHOD(removeSegmentFromUserPreference, segment:(nonnull NSDictionary*)segment userPreference:(nonnull NSDictionary*)userPreference removeSegmentFromUserPreferenceWithResolver:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject) {
    
    [[[NotificarePushLib shared] authManager] removeSegment:[[NotificareReactNativeIOSUtils shared] segmentFromDictionary:segment] fromPreference:[[NotificareReactNativeIOSUtils shared] userPreferenceFromDictionary:userPreference] completionHandler:^(id  _Nullable response, NSError * _Nullable error) {
        if (!error) {
            resolve(response);
        } else {
            reject(@"error", [error description], error);
        }
    }];
    
}


@end

/**
 *
 * Helper class to handle NotificarePushLib delegates
 *
 */
@implementation PushHandler

- (void)notificarePushLib:(NotificarePushLib *)library onReady:(nonnull NotificareApplication *)application {
    [[NotificareReactNativeIOS getInstance] dispatchEvent:@"ready" body:[[NotificareReactNativeIOSUtils shared] dictionaryFromApplication:application]];
}

- (void)notificarePushLib:(NotificarePushLib *)library didRegisterDevice:(nonnull NotificareDevice *)device{
    [[NotificareReactNativeIOS getInstance] dispatchEvent:@"deviceRegistered" body:[[NotificareReactNativeIOSUtils shared] dictionaryFromDevice:device]];
}

- (void)notificarePushLib:(NotificarePushLib *)library didChangeNotificationSettings:(BOOL)granted{
    NSMutableDictionary * payload = [NSMutableDictionary new];
    [payload setObject:[NSNumber numberWithBool:granted] forKey:@"granted"];
    [[NotificareReactNativeIOS getInstance] dispatchEvent:@"notificationSettingsChanged" body:payload];
}

- (void)notificarePushLib:(NotificarePushLib *)library didReceiveLaunchURL:(NSURL *)launchURL{
    NSMutableDictionary * payload = [NSMutableDictionary new];
    [payload setObject:[launchURL absoluteString] forKey:@"url"];
    [[NotificareReactNativeIOS getInstance] dispatchEvent:@"launchUrlReceived" body:payload];
}

- (void)notificarePushLib:(NotificarePushLib *)library didReceiveRemoteNotificationInBackground:(NotificareNotification *)notification withController:(id _Nullable)controller{
    [[NotificareReactNativeIOS getInstance] dispatchEvent:@"remoteNotificationReceivedInBackground" body:[[NotificareReactNativeIOSUtils shared] dictionaryFromNotification:notification]];
}

- (void)notificarePushLib:(NotificarePushLib *)library didReceiveRemoteNotificationInForeground:(NotificareNotification *)notification withController:(id _Nullable)controller{
    [[NotificareReactNativeIOS getInstance] dispatchEvent:@"remoteNotificationReceivedInForeground" body:[[NotificareReactNativeIOSUtils shared] dictionaryFromNotification:notification]];
}

- (void)notificarePushLib:(NotificarePushLib *)library didReceiveSystemNotificationInBackground:(NotificareSystemNotification *)notification{
    [[NotificareReactNativeIOS getInstance] dispatchEvent:@"systemNotificationReceivedInBackground" body:[[NotificareReactNativeIOSUtils shared] dictionaryFromSystemNotification:notification]];
}

- (void)notificarePushLib:(NotificarePushLib *)library didReceiveSystemNotificationInForeground:(NotificareSystemNotification *)notification{
    [[NotificareReactNativeIOS getInstance] dispatchEvent:@"systemNotificationReceivedInForeground" body:[[NotificareReactNativeIOSUtils shared] dictionaryFromSystemNotification:notification]];
}

- (void)notificarePushLib:(NotificarePushLib *)library didReceiveUnknownNotification:(NSDictionary *)notification{
    [[NotificareReactNativeIOS getInstance] dispatchEvent:@"unknownNotificationReceived" body:notification];
}

- (void)notificarePushLib:(NotificarePushLib *)library didReceiveUnknownAction:(NSDictionary *)action forNotification:(NSDictionary *)notification{
    NSMutableDictionary * payload = [NSMutableDictionary new];
    [payload setObject:action forKey:@"action"];
    [payload setObject:notification forKey:@"notification"];
    [[NotificareReactNativeIOS getInstance] dispatchEvent:@"unknownActionForNotificationReceived" body:payload];
}

- (void)notificarePushLib:(NotificarePushLib *)library willOpenNotification:(NotificareNotification *)notification{
    [[NotificareReactNativeIOS getInstance] dispatchEvent:@"notificationWillOpen" body:[[NotificareReactNativeIOSUtils shared] dictionaryFromNotification:notification]];
}

- (void)notificarePushLib:(NotificarePushLib *)library didOpenNotification:(NotificareNotification *)notification{
    [[NotificareReactNativeIOS getInstance] dispatchEvent:@"notificationOpened" body:[[NotificareReactNativeIOSUtils shared] dictionaryFromNotification:notification]];
}

- (void)notificarePushLib:(NotificarePushLib *)library didCloseNotification:(NotificareNotification *)notification{
    [[NotificareReactNativeIOS getInstance] dispatchEvent:@"notificationClosed" body:[[NotificareReactNativeIOSUtils shared] dictionaryFromNotification:notification]];
}

- (void)notificarePushLib:(NotificarePushLib *)library didFailToOpenNotification:(NotificareNotification *)notification{
    [[NotificareReactNativeIOS getInstance] dispatchEvent:@"notificationFailedToOpen" body:[[NotificareReactNativeIOSUtils shared] dictionaryFromNotification:notification]];
}

- (void)notificarePushLib:(NotificarePushLib *)library didClickURL:(NSURL *)url inNotification:(NotificareNotification *)notification{
    NSMutableDictionary * payload = [NSMutableDictionary new];
    [payload setObject:[url absoluteString] forKey:@"url"];
    [payload setObject:[[NotificareReactNativeIOSUtils shared] dictionaryFromNotification:notification] forKey:@"notification"];
    [[NotificareReactNativeIOS getInstance] dispatchEvent:@"urlClickedInNotification" body:payload];
}

- (void)notificarePushLib:(NotificarePushLib *)library willExecuteAction:(NotificareAction *)action{
    [[NotificareReactNativeIOS getInstance] dispatchEvent:@"actionWillExecute" body:[[NotificareReactNativeIOSUtils shared] dictionaryFromAction:action]];
}

- (void)notificarePushLib:(NotificarePushLib *)library didExecuteAction:(NotificareAction *)action{
    [[NotificareReactNativeIOS getInstance] dispatchEvent:@"actionExecuted" body:[[NotificareReactNativeIOSUtils shared] dictionaryFromAction:action]];
}

- (void)notificarePushLib:(NotificarePushLib *)library shouldPerformSelectorWithURL:(NSURL *)url inAction:(NotificareAction *)action{
    NSMutableDictionary * payload = [NSMutableDictionary new];
    [payload setObject:[url absoluteString] forKey:@"url"];
    [payload setObject:[[NotificareReactNativeIOSUtils shared] dictionaryFromAction:action] forKey:@"action"];
    [[NotificareReactNativeIOS getInstance] dispatchEvent:@"shouldPerformSelectorWithUrl" body:payload];
}

- (void)notificarePushLib:(NotificarePushLib *)library didNotExecuteAction:(NotificareAction *)action{
     [[NotificareReactNativeIOS getInstance] dispatchEvent:@"actionNotExecuted" body:[[NotificareReactNativeIOSUtils shared] dictionaryFromAction:action]];
}

- (void)notificarePushLib:(NotificarePushLib *)library didFailToExecuteAction:(NotificareAction *)action withError:(NSError *)error{
     [[NotificareReactNativeIOS getInstance] dispatchEvent:@"actionFailedToExecute" body:[[NotificareReactNativeIOSUtils shared] dictionaryFromAction:action]];
}

/*
 * Uncomment this code and implement PKAddPassesViewController
- (void)notificarePushLib:(NotificarePushLib *)library didReceivePass:(NSURL *)pass inNotification:(NotificareNotification*)notification{
    
    NSData *data = [[NSData alloc] initWithContentsOfURL:pass];
    NSError *error;
    
    //init a pass object with the data
    PKPass * pkPass = [[PKPass alloc] initWithData:data error:&error];
    
    if(!error){
        //present view controller to add the pass to the library
        PKAddPassesViewController * vc = [[PKAddPassesViewController alloc] initWithPass:pkPass];
        [vc setDelegate:self];
 
        [[NotificarePushLib shared] presentWalletPass:notification inNavigationController:[[NotificareReactNativeIOS getInstance] navigationControllerForRootViewController] withController:vc];
        
    }
    
}
 */

- (void)notificarePushLib:(NotificarePushLib *)library shouldOpenSettings:(NotificareNotification* _Nullable)notification{
    [[NotificareReactNativeIOS getInstance] dispatchEvent:@"shouldOpenSettings" body:[[NotificareReactNativeIOSUtils shared] dictionaryFromNotification:notification]];
}


- (void)notificarePushLib:(NotificarePushLib *)library didLoadInbox:(NSArray<NotificareDeviceInbox*>*)items{
    NSMutableArray * inboxItems = [NSMutableArray array];
    for (NotificareDeviceInbox * inboxItem in items) {
        [inboxItems addObject:[[NotificareReactNativeIOSUtils shared] dictionaryFromDeviceInbox:inboxItem]];
    }
    [[NotificareReactNativeIOS getInstance] dispatchEvent:@"inboxLoaded" body:inboxItems];
}

- (void)notificarePushLib:(NotificarePushLib *)library didUpdateBadge:(int)badge{
    [[NotificareReactNativeIOS getInstance] dispatchEvent:@"badgeUpdated" body:[NSNumber numberWithInt:badge]];
}


- (void)notificarePushLib:(NotificarePushLib *)library didFailToStartLocationServiceWithError:(NSError *)error{
    NSMutableDictionary * payload = [NSMutableDictionary new];
    [payload setObject:[error localizedDescription] forKey:@"error"];
    [[NotificareReactNativeIOS getInstance] dispatchEvent:@"locationServiceFailedToStart" body:payload];
}

- (void)notificarePushLib:(NotificarePushLib *)library didReceiveLocationServiceAuthorizationStatus:(NotificareGeoAuthorizationStatus)status{
    
}

- (void)notificarePushLib:(NotificarePushLib *)library didUpdateLocations:(NSArray<NotificareLocation*> *)locations{
    NSMutableArray * payload = [NSMutableArray new];
    for (NotificareLocation * location in locations) {
        [payload addObject:[[NotificareReactNativeIOSUtils shared] dictionaryFromLocation:location]];
    }
    [[NotificareReactNativeIOS getInstance] dispatchEvent:@"locationsUpdated" body:payload];
}

- (void)notificarePushLib:(NotificarePushLib *)library monitoringDidFailForRegion:(id)region withError:(NSError *)error{
    NSMutableDictionary * payload = [NSMutableDictionary new];
    [payload setObject:[error localizedDescription] forKey:@"error"];
    [[NotificareReactNativeIOS getInstance] dispatchEvent:@"monitoringForRegionFailed" body:payload];
}

- (void)notificarePushLib:(NotificarePushLib *)library didStartMonitoringForRegion:(id)region{
    
    if([region isKindOfClass:[NotificareRegion class]]){
        [[NotificareReactNativeIOS getInstance] dispatchEvent:@"monitoringForRegionStarted" body:[[NotificareReactNativeIOSUtils shared] dictionaryFromRegion:region]];
    }
    
    if([region isKindOfClass:[NotificareBeacon class]]){
        [[NotificareReactNativeIOS getInstance] dispatchEvent:@"monitoringForRegionStarted" body:[[NotificareReactNativeIOSUtils shared] dictionaryFromBeacon:region]];
    }
}

- (void)notificarePushLib:(NotificarePushLib *)library didDetermineState:(NotificareRegionState)state forRegion:(id)region{
    
    NSMutableDictionary * payload = [NSMutableDictionary new];
    
    if (state == NotificareRegionStateInside) {
        [payload setObject:@"inside" forKey:@"state"];
    } else if (state == NotificareRegionStateOutside) {
        [payload setObject:@"outside" forKey:@"state"];
    } else if (state == NotificareRegionStateUnknown) {
        [payload setObject:@"unknown" forKey:@"state"];
    }
    
    if([region isKindOfClass:[NotificareRegion class]]){
        [payload setObject:[[NotificareReactNativeIOSUtils shared] dictionaryFromRegion:region] forKey:@"region"];
    }
    
    if([region isKindOfClass:[NotificareBeacon class]]){
        [payload setObject:[[NotificareReactNativeIOSUtils shared] dictionaryFromRegion:region] forKey:@"region"];
    }
    
    [[NotificareReactNativeIOS getInstance] dispatchEvent:@"stateForRegionChanged" body:payload];
}

- (void)notificarePushLib:(NotificarePushLib *)library didEnterRegion:(id)region{
    
    if([region isKindOfClass:[NotificareRegion class]]){
        [[NotificareReactNativeIOS getInstance] dispatchEvent:@"regionEntered" body:[[NotificareReactNativeIOSUtils shared] dictionaryFromRegion:region]];
    }
    
    if([region isKindOfClass:[NotificareBeacon class]]){
        [[NotificareReactNativeIOS getInstance] dispatchEvent:@"regionEntered" body:[[NotificareReactNativeIOSUtils shared] dictionaryFromBeacon:region]];
    }
}

- (void)notificarePushLib:(NotificarePushLib *)library didExitRegion:(id)region{
    
    if([region isKindOfClass:[NotificareRegion class]]){
        [[NotificareReactNativeIOS getInstance] dispatchEvent:@"regionExited" body:[[NotificareReactNativeIOSUtils shared] dictionaryFromRegion:region]];
    }
    
    if([region isKindOfClass:[NotificareBeacon class]]){
        [[NotificareReactNativeIOS getInstance] dispatchEvent:@"regionExited" body:[[NotificareReactNativeIOSUtils shared] dictionaryFromBeacon:region]];
    }
    
}

- (void)notificarePushLib:(NotificarePushLib *)library rangingBeaconsDidFailForRegion:(NotificareBeacon *)region withError:(NSError *)error{
    NSMutableDictionary * payload = [NSMutableDictionary new];
    [payload setObject:[error localizedDescription] forKey:@"error"];
    [payload setObject:[[NotificareReactNativeIOSUtils shared] dictionaryFromBeacon:region] forKey:@"region"];
    [[NotificareReactNativeIOS getInstance] dispatchEvent:@"rangingBeaconsFailed" body:payload];
}

- (void)notificarePushLib:(NotificarePushLib *)library didRangeBeacons:(NSArray<NotificareBeacon *> *)beacons inRegion:(NotificareBeacon *)region{
    NSMutableDictionary * payload = [NSMutableDictionary new];
    NSMutableArray * beaconsList = [NSMutableArray new];
    for (NotificareBeacon * beacon in beacons) {
        [beaconsList addObject:[[NotificareReactNativeIOSUtils shared] dictionaryFromBeacon:beacon]];
    }
    [payload setObject:beaconsList forKey:@"beacons"];
    [payload setObject:[[NotificareReactNativeIOSUtils shared] dictionaryFromBeacon:region] forKey:@"region"];
    [[NotificareReactNativeIOS getInstance] dispatchEvent:@"beaconsInRangeForRegion" body:payload];
}

- (void)notificarePushLib:(NotificarePushLib *)library didUpdateHeading:(NotificareHeading*)heading{
    
}

- (void)notificarePushLib:(NotificarePushLib *)library didVisit:(NotificareVisit*)visit{
    
}


- (void)notificarePushLib:(NotificarePushLib *)library didChangeAccountState:(NSDictionary *)info{}

- (void)notificarePushLib:(NotificarePushLib *)library didFailToRenewAccountSessionWithError:(NSError * _Nullable)error{}

- (void)notificarePushLib:(NotificarePushLib *)library didReceiveActivationToken:(NSString *)token{}

- (void)notificarePushLib:(NotificarePushLib *)library didReceiveResetPasswordToken:(NSString *)token{}


- (void)notificarePushLib:(NotificarePushLib *)library didLoadStore:(NSArray<NotificareProduct *> *)products{}

- (void)notificarePushLib:(NotificarePushLib *)library didFailToLoadStore:(NSError *)error{}

- (void)notificarePushLib:(NotificarePushLib *)library didCompleteProductTransaction:(SKPaymentTransaction *)transaction{}

- (void)notificarePushLib:(NotificarePushLib *)library didRestoreProductTransaction:(SKPaymentTransaction *)transaction{}

- (void)notificarePushLib:(NotificarePushLib *)library didFailProductTransaction:(SKPaymentTransaction *)transaction withError:(NSError *)error{}

- (void)notificarePushLib:(NotificarePushLib *)library didStartDownloadContent:(SKPaymentTransaction *)transaction{}

- (void)notificarePushLib:(NotificarePushLib *)library didPauseDownloadContent:(SKDownload *)download{}

- (void)notificarePushLib:(NotificarePushLib *)library didCancelDownloadContent:(SKDownload *)download{}

- (void)notificarePushLib:(NotificarePushLib *)library didReceiveProgressDownloadContent:(SKDownload *)download{}

- (void)notificarePushLib:(NotificarePushLib *)library didFailDownloadContent:(SKDownload *)download{}

- (void)notificarePushLib:(NotificarePushLib *)library didFinishDownloadContent:(SKDownload *)download{}


- (void)notificarePushLib:(NotificarePushLib *)library didStartQRCodeScanner:(UIViewController*)scanner{}

- (void)notificarePushLib:(NotificarePushLib *)library didInvalidateScannableSessionWithError:(NSError *)error{}

- (void)notificarePushLib:(NotificarePushLib *)library didDetectScannable:(NotificareScannable *)scannable{}

@end
