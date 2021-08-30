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
#import "NotificareReactNativeIOSPushHandler.h"
#import "UIImage+FromBundle.h"
#import "NotificareNone.h"
#import "NotificareURLScheme.h"
#import "UIColor+Hex.h"

@implementation NotificareReactNativeIOS

@synthesize bridge = _bridge;

static NotificareReactNativeIOS *instance = nil;
API_AVAILABLE(ios(10.0))
static UNAuthorizationOptions authorizationOptions = UNAuthorizationOptionBadge + UNAuthorizationOptionSound + UNAuthorizationOptionAlert;
API_AVAILABLE(ios(10.0))
static UNNotificationPresentationOptions presentationOptions = UNNotificationPresentationOptionNone;
API_AVAILABLE(ios(10.0))
static UNNotificationCategoryOptions categoryOptions = UNNotificationCategoryOptionCustomDismissAction;

#define NOTIFICARE_ERROR @"notificare_error"


+ (NotificareReactNativeIOS *)getInstance {
  return instance;
}

+ (void)launch:(NSDictionary *)launchOptions {
    [[NotificarePushLib shared] initializeWithKey:nil andSecret:nil];
    [[NotificarePushLib shared] setDelegate:[NotificareReactNativeIOSPushHandler shared]];
    [[NotificarePushLib shared] didFinishLaunchingWithOptions:launchOptions];
    
    if (@available(iOS 10.0, *)) {
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

+ (BOOL)continueUserActivity:(NSUserActivity *)userActivity restorationHandler:(void (^)(NSArray * _Nonnull))restorationHandler {
    return [[NotificarePushLib shared] continueUserActivity:userActivity restorationHandler:restorationHandler];
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

+ (BOOL)handleOpenURL:(nonnull NSURL *)url withOptions:(NSDictionary * _Nullable)options{
    BOOL granted = [[NotificarePushLib shared] handleOpenURL:url withOptions:options];

    NSMutableDictionary * payload = [NSMutableDictionary new];
    [payload setObject:[url absoluteString] forKey:@"url"];
    [payload setObject:options forKey:@"options"];
    [[NotificareReactNativeIOSPushHandler shared] dispatchEvent:@"urlOpened" body:payload];

    return granted;
}

+ (nullable NSString *)parseURIPayload:(NSData*)data{
    return [[NotificarePushLib shared] parseURIPayload:data];
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
             @"locationServiceAuthorizationStatusReceived",
             @"locationServiceAccuracyAuthorizationReceived",
             @"locationsUpdated",
             @"monitoringForRegionFailed",
             @"monitoringForRegionStarted",
             @"stateForRegionChanged",
             @"regionEntered",
             @"regionExited",
             @"rangingBeaconsFailed",
             @"beaconsInRangeForRegion",
             @"headingUpdated",
             @"visitReceived",
             @"activationTokenReceived",
             @"resetPasswordTokenReceived",
             @"storeLoaded",
             @"storeFailedToLoad",
             @"productTransactionCompleted",
             @"productTransactionRestored",
             @"productTransactionFailed",
             @"productContentDownloadStarted",
             @"productContentDownloadPaused",
             @"productContentDownloadCancelled",
             @"productContentDownloadProgress",
             @"productContentDownloadFailed",
             @"productContentDownloadFinished",
             @"qrCodeScannerStarted",
             @"scannableSessionInvalidatedWithError",
             @"scannableDetected"
            ];
}

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
    [[navController view] setBackgroundColor:[UIColor whiteColor]];

    UIViewController* notificationController = (UIViewController *)object;
    NSDictionary* theme = [[NotificareAppConfig shared] themeForController:notificationController];

    UIBarButtonItem* closeButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageFromBundle:@"closeIcon"] style:UIBarButtonItemStylePlain target:self action:@selector(close)];
    if (theme && [theme objectForKey:@"ACTION_BUTTON_TEXT_COLOR"]) {
        [closeButton setTintColor:[UIColor colorWithHexString:[theme objectForKey:@"ACTION_BUTTON_TEXT_COLOR"]]];
    }

    [[notificationController navigationItem] setLeftBarButtonItem: closeButton];

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
        [[controller class] isEqual:[NotificareNone class]] ||
        [[controller class] isEqual:[NotificareURLScheme class]] ||
        controller == nil) {
        result = NO;
    }
    return result;
}

RCT_EXPORT_MODULE()

RCT_EXPORT_METHOD(launch){
    [[NotificarePushLib shared] launch];
}

RCT_EXPORT_METHOD(unlaunch){
    [[NotificarePushLib shared] unlaunch];
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
    
    if (@available(iOS 10.0, *)) {
        [[[NotificarePushLib shared] userNotificationCenter] getNotificationSettingsWithCompletionHandler:^(UNNotificationSettings * _Nonnull settings) {
            resolve([[NotificareReactNativeIOSUtils shared] dictionaryFromNotificationSettings:settings]);
        }];
    }
    
}


RCT_EXPORT_METHOD(startLocationUpdates) {
  [[NotificarePushLib shared] startLocationUpdates];
}

RCT_EXPORT_METHOD(stopLocationUpdates) {
    [[NotificarePushLib shared] stopLocationUpdates];
}

RCT_REMAP_METHOD(clearLocation, clearLocationWithResolver:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject) {
    [[NotificarePushLib shared] clearDeviceLocation:^(id  _Nullable response, NSError * _Nullable error) {
        if (!error) {
            resolve(nil);
        } else {
           reject(NOTIFICARE_ERROR, [error localizedDescription], error);
        }
    }];
}

RCT_EXPORT_METHOD(enableBeacons) {
  // no-op
}

RCT_EXPORT_METHOD(disableBeacons) {
  // no-op
}

RCT_EXPORT_METHOD(enableBeaconForegroundService) {
    // no-op
}

RCT_EXPORT_METHOD(disableBeaconForegroundService) {
    // no-op
}

RCT_REMAP_METHOD(isLocationServicesEnabled, isLocationServicesEnabledWithResolver:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject) {
    resolve(@([[NotificarePushLib shared] locationServicesEnabled]));
}

RCT_REMAP_METHOD(registerDevice, userID:(NSString * _Nullable)userID userName:(NSString * _Nullable)userName registerDeviceWithResolver:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject) {
    
    [[NotificarePushLib shared] registerDevice:userID withUsername:userName completionHandler:^(id  _Nullable response, NSError * _Nullable error) {
        if (!error) {
            resolve([[NotificareReactNativeIOSUtils shared] dictionaryFromDevice:response]);
        } else {
           reject(NOTIFICARE_ERROR, [error localizedDescription], error);
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
            resolve(nil);
        } else {
            reject(NOTIFICARE_ERROR, [error localizedDescription], error);
        }
    }];
    
}

RCT_REMAP_METHOD(fetchTags, fetchTagsWithResolver:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject) {
    
    [[NotificarePushLib shared] fetchTags:^(id  _Nullable response, NSError * _Nullable error) {
        if (!error) {
            resolve(response);
        } else {
            reject(NOTIFICARE_ERROR, [error localizedDescription], error);
        }
    }];
    
}

RCT_REMAP_METHOD(addTag, tag:(nonnull NSString *)tag addTagWithResolver:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject) {
    
    [[NotificarePushLib shared] addTag:tag completionHandler:^(id  _Nullable response, NSError * _Nullable error) {
        if (!error) {
            resolve(nil);
        } else {
            reject(NOTIFICARE_ERROR, [error localizedDescription], error);
        }
    }];
}

RCT_REMAP_METHOD(addTags, tags:(nonnull NSArray *)tags addTagsWithResolver:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject) {
    
    [[NotificarePushLib shared] addTags:tags completionHandler:^(id  _Nullable response, NSError * _Nullable error) {
        if (!error) {
            resolve(nil);
        } else {
            reject(NOTIFICARE_ERROR, [error localizedDescription], error);
        }
    }];
}

RCT_REMAP_METHOD(removeTag, tag:(nonnull NSString *)tag removeTagWithResolver:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject) {
    
    [[NotificarePushLib shared] removeTag:tag completionHandler:^(id  _Nullable response, NSError * _Nullable error) {
        if (!error) {
            resolve(nil);
        } else {
            reject(NOTIFICARE_ERROR, [error localizedDescription], error);
        }
    }];
}


RCT_REMAP_METHOD(removeTags, tags:(nonnull NSArray *)tags removeTagsWithResolver:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject) {
    
    [[NotificarePushLib shared] removeTags:tags completionHandler:^(id  _Nullable response, NSError * _Nullable error) {
        if (!error) {
            resolve(nil);
        } else {
            reject(NOTIFICARE_ERROR, [error localizedDescription], error);
        }
    }];
}

RCT_REMAP_METHOD(clearTags, clearTagsWithResolver:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject) {
    
    [[NotificarePushLib shared] clearTags:^(id  _Nullable response, NSError * _Nullable error) {
        if (!error) {
            resolve(nil);
        } else {
            reject(NOTIFICARE_ERROR, [error localizedDescription], error);
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
            reject(NOTIFICARE_ERROR, [error localizedDescription], error);
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
            resolve(nil);
        } else {
            reject(NOTIFICARE_ERROR, [error localizedDescription], error);
        }
    }];
    
}


RCT_REMAP_METHOD(fetchDoNotDisturb, fetchDoNotDisturbWithResolver:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject) {
    
    [[NotificarePushLib shared] fetchDoNotDisturb:^(id  _Nullable response, NSError * _Nullable error) {
        if (!error) {
            resolve([[NotificareReactNativeIOSUtils shared] dictionaryFromDeviceDnD:response]);
        } else {
            reject(NOTIFICARE_ERROR, [error localizedDescription], error);
        }
    }];
    
}

RCT_REMAP_METHOD(updateDoNotDisturb, deviceDnD:(nonnull NSDictionary *)deviceDnD updateDoNotDisturbWithResolver:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject) {
    
    [[NotificarePushLib shared] updateDoNotDisturb:[[NotificareReactNativeIOSUtils shared] deviceDnDFromDictionary:deviceDnD] completionHandler:^(id  _Nullable response, NSError * _Nullable error) {
        if (!error) {
            resolve([[NotificareReactNativeIOSUtils shared] dictionaryFromDeviceDnD:response]);
        } else {
            reject(NOTIFICARE_ERROR, [error localizedDescription], error);
        }
    }];
    
}

RCT_REMAP_METHOD(clearDoNotDisturb, clearDoNotDisturbWithResolver:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject) {
    
    [[NotificarePushLib shared] clearDoNotDisturb:^(id  _Nullable response, NSError * _Nullable error) {
        if (!error) {
            resolve([[NotificareReactNativeIOSUtils shared] dictionaryFromDeviceDnD:response]);
        } else {
            reject(NOTIFICARE_ERROR, [error localizedDescription], error);
        }
    }];
    
}

RCT_REMAP_METHOD(fetchNotification, notification:(nonnull NSDictionary *)notification fetchNotificationWithResolver:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject) {
    
    [[NotificarePushLib shared] fetchNotification:notification completionHandler:^(id  _Nullable response, NSError * _Nullable error) {
        if (!error) {
            resolve([[NotificareReactNativeIOSUtils shared] dictionaryFromNotification:response]);
        } else {
            reject(NOTIFICARE_ERROR, [error localizedDescription], error);
        }
    }];
    
}

RCT_REMAP_METHOD(fetchNotificationForInboxItem, inboxItem:(nonnull NSDictionary *)inboxItem fetchNotificationForInboxItemWithResolver:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject) {
    
    [[NotificarePushLib shared] fetchNotification:[inboxItem objectForKey:@"inboxId"] completionHandler:^(id  _Nullable response, NSError * _Nullable error) {
        if (!error) {
            resolve([[NotificareReactNativeIOSUtils shared] dictionaryFromNotification:response]);
        } else {
            reject(NOTIFICARE_ERROR, [error localizedDescription], error);
        }
    }];
    
}

RCT_EXPORT_METHOD(presentNotification:(nonnull NSDictionary*)notification) {
    
    dispatch_async(dispatch_get_main_queue(), ^{
        NotificareNotification * item = [[NotificareReactNativeIOSUtils shared] notificationFromDictionary:notification];
        id controller = [[NotificarePushLib shared] controllerForNotification:item];
        if ([self isViewController:controller]) {
            UINavigationController *navController = [self navigationControllerForViewControllers:controller];
            [[[[UIApplication sharedApplication] keyWindow] rootViewController] presentViewController:navController animated:YES completion:^{
                [[NotificarePushLib shared] presentNotification:item inNavigationController:navController withController:controller];
            }];
        } else {
            [[NotificarePushLib shared] presentNotification:item inNavigationController:[self navigationControllerForRootViewController] withController:controller];
        }
    });

}

RCT_REMAP_METHOD(reply, notification:(nonnull NSDictionary *)notification action:(nonnull NSDictionary *)action data:(nonnull NSDictionary *)data replyWithResolver:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject) {
    
    [[NotificarePushLib shared] reply:[[NotificareReactNativeIOSUtils shared] notificationFromDictionary:notification] forAction:[[NotificareReactNativeIOSUtils shared] actionFromDictionary:action]  andData:data completionHandler:^(id  _Nullable response, NSError * _Nullable error) {
        if (!error) {
            resolve(nil);
        } else {
            reject(NOTIFICARE_ERROR, [error localizedDescription], error);
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
            reject(NOTIFICARE_ERROR, [error localizedDescription], error);
        }
    }];
    
}

RCT_EXPORT_METHOD(presentInboxItem:(nonnull NSDictionary*)inboxItem) {
    
    dispatch_async(dispatch_get_main_queue(), ^{
        NotificareDeviceInbox * item = [[NotificareReactNativeIOSUtils shared] deviceInboxFromDictionary:inboxItem];
        [[[NotificarePushLib shared] inboxManager] openInboxItem:item completionHandler:^(id  _Nullable response, NSError * _Nullable error) {
            if (!error) {
                if ([self isViewController:response]) {
                    UINavigationController *navController = [self navigationControllerForViewControllers:response];
                    [[[[UIApplication sharedApplication] keyWindow] rootViewController] presentViewController:navController animated:YES completion:^{
                        [[NotificarePushLib shared] presentInboxItem:item inNavigationController:navController withController:response];
                    }];
                } else {
                    [[NotificarePushLib shared] presentInboxItem:item inNavigationController:[self navigationControllerForRootViewController] withController:response];
                }
            }
        }];
    });
    
}

RCT_REMAP_METHOD(removeFromInbox, inboxItem:(nonnull NSDictionary*)inboxItem removeFromInboxWithResolver:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject) {
    
    [[[NotificarePushLib shared] inboxManager] removeFromInbox:[[NotificareReactNativeIOSUtils shared] deviceInboxFromDictionary:inboxItem] completionHandler:^(id  _Nullable response, NSError * _Nullable error) {
        if (!error) {
            resolve([[NotificareReactNativeIOSUtils shared] dictionaryFromDeviceInbox:response]);
        } else {
            reject(NOTIFICARE_ERROR, [error localizedDescription], error);
        }
    }];
    
}

RCT_REMAP_METHOD(markAsRead, inboxItem:(nonnull NSDictionary*)inboxItem markAsReadWithResolver:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject) {
    
    [[[NotificarePushLib shared] inboxManager] markAsRead:[[NotificareReactNativeIOSUtils shared] deviceInboxFromDictionary:inboxItem] completionHandler:^(id  _Nullable response, NSError * _Nullable error) {
        if (!error) {
            resolve([[NotificareReactNativeIOSUtils shared] dictionaryFromDeviceInbox:response]);
        } else {
            reject(NOTIFICARE_ERROR, [error localizedDescription], error);
        }
    }];
    
}

RCT_REMAP_METHOD(markAllAsRead, markAllAsReadWithResolver:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject) {

    [[[NotificarePushLib shared] inboxManager] markAllAsRead:^(id  _Nullable response, NSError * _Nullable error) {
        if (!error) {
            resolve(nil);
        } else {
            reject(NOTIFICARE_ERROR, [error localizedDescription], error);
        }
    }];

}

RCT_REMAP_METHOD(clearInbox, clearInboxWithResolver:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject) {
    
    [[[NotificarePushLib shared] inboxManager] clearInbox:^(id  _Nullable response, NSError * _Nullable error) {
        if (!error) {
            resolve(nil);
        } else {
            reject(NOTIFICARE_ERROR, [error localizedDescription], error);
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
            reject(NOTIFICARE_ERROR, [error localizedDescription], error);
        }
    }];
    
}


RCT_REMAP_METHOD(fetchPassWithSerial, serial:(nonnull NSString*)serial fetchPassWithSerialWithResolver:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject) {
    
    [[NotificarePushLib shared] fetchPassWithSerial:serial completionHandler:^(id  _Nullable response, NSError * _Nullable error) {
        if (!error) {
            resolve([[NotificareReactNativeIOSUtils shared] dictionaryFromPass:response]);
        } else {
            reject(NOTIFICARE_ERROR, [error localizedDescription], error);
        }
    }];
    
}

RCT_REMAP_METHOD(fetchPassWithBarcode, barcode:(nonnull NSString*)barcode fetchPassWithBarcodeWithResolver:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject) {
    
    [[NotificarePushLib shared] fetchPassWithBarcode:barcode completionHandler:^(id  _Nullable response, NSError * _Nullable error) {
        if (!error) {
            resolve([[NotificareReactNativeIOSUtils shared] dictionaryFromPass:response]);
        } else {
            reject(NOTIFICARE_ERROR, [error localizedDescription], error);
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
            reject(NOTIFICARE_ERROR, [error localizedDescription], error);
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
            reject(NOTIFICARE_ERROR, [error localizedDescription], error);
        }
    }];
    
}

RCT_REMAP_METHOD(fetchProduct, product:(nonnull NSDictionary*)product fetchProductWithResolver:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject) {
    
    [[NotificarePushLib shared] fetchProduct:[product objectForKey:@"productIdentifier"] completionHandler:^(id  _Nullable response, NSError * _Nullable error) {
        if (!error) {
            resolve([[NotificareReactNativeIOSUtils shared] dictionaryFromProduct:response]);
        } else {
            reject(NOTIFICARE_ERROR, [error localizedDescription], error);
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

RCT_EXPORT_METHOD(enableBilling) {
  // no-op
}

RCT_EXPORT_METHOD(disableBilling) {
  // no-op
}


RCT_REMAP_METHOD(logCustomEvent, name:(nonnull NSString*)name data:(NSDictionary* _Nullable)data logCustomEventWithResolver:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject) {
    
    [[NotificarePushLib shared] logCustomEvent:name withData:data completionHandler:^(id  _Nullable response, NSError * _Nullable error) {
        if (!error) {
            resolve(nil);
        } else {
            reject(NOTIFICARE_ERROR, [error localizedDescription], error);
        }
    }];
    
}

RCT_REMAP_METHOD(logOpenNotification, notification:(NSDictionary* _Nullable)notification logOpenNotificationWithResolver:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject) {
    
    NSMutableDictionary * eventData = [NSMutableDictionary dictionary];
    [eventData setObject:[notification objectForKey:@"id"] forKey:@"notification"];
    
    [[NotificarePushLib shared] logEvent:kNotificareEventNotificationOpen withData:eventData completionHandler:^(id  _Nullable response, NSError * _Nullable error) {
        if (!error) {
            resolve(nil);
        } else {
            reject(NOTIFICARE_ERROR, [error localizedDescription], error);
        }
    }];
    
}

RCT_REMAP_METHOD(logInfluencedNotification, notification:(NSDictionary* _Nullable)notification logInfluencedNotificationWithResolver:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject) {
    
    NSMutableDictionary * eventData = [NSMutableDictionary dictionary];
    [eventData setObject:[notification objectForKey:@"id"] forKey:@"notification"];
    
    [[NotificarePushLib shared] logEvent:kNotificareEventNotificationInfluenced withData:eventData completionHandler:^(id  _Nullable response, NSError * _Nullable error) {
        if (!error) {
            resolve(nil);
        } else {
            reject(NOTIFICARE_ERROR, [error localizedDescription], error);
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
            reject(NOTIFICARE_ERROR, [error localizedDescription], error);
        }
    }];
    
}

RCT_REMAP_METHOD(doPushHostOperation, verb:(nonnull NSString*)verb path:(nonnull NSString*)path params:(NSDictionary * _Nullable)params body:(NSDictionary* _Nullable)body doPushHostOperationWithResolver:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject) {
    
    [[NotificarePushLib shared] doPushHostOperation:verb path:path URLParams:params bodyJSON:body completionHandler:^(id  _Nullable response, NSError * _Nullable error) {
        if (!error) {
            resolve(response);
        } else {
            reject(NOTIFICARE_ERROR, [error localizedDescription], error);
        }
    }];
    
}

RCT_REMAP_METHOD(doCloudHostOperation, verb:(nonnull NSString*)verb path:(nonnull NSString*)path params:(NSDictionary * _Nullable)params headers:(NSDictionary * _Nullable)headers body:(NSDictionary* _Nullable)body doCloudHostOperationWithResolver:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject) {
    
    [[NotificarePushLib shared] doCloudHostOperation:verb path:path URLParams:params customHeaders:headers bodyJSON:body completionHandler:^(id  _Nullable response, NSError * _Nullable error) {
        if (!error) {
            resolve(response);
        } else {
            reject(NOTIFICARE_ERROR, [error localizedDescription], error);
        }
    }];
    
}

RCT_REMAP_METHOD(createAccount, email:(nonnull NSString*)email name:(nonnull NSString*)name password:(nonnull NSString*)password createAccountWithResolver:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject) {
    
    [[[NotificarePushLib shared] authManager] createAccount:email withName:name andPassword:password completionHandler:^(id  _Nullable response, NSError * _Nullable error) {
        if (!error) {
            resolve(nil);
        } else {
            reject(NOTIFICARE_ERROR, [error localizedDescription], error);
        }
    }];
    
}

RCT_REMAP_METHOD(validateAccount, token:(nonnull NSString*)token validateAccountWithResolver:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject) {
    
    [[[NotificarePushLib shared] authManager] validateAccount:token completionHandler:^(id  _Nullable response, NSError * _Nullable error) {
        if (!error) {
            resolve(nil);
        } else {
            reject(NOTIFICARE_ERROR, [error localizedDescription], error);
        }
    }];
    
}

RCT_REMAP_METHOD(resetPassword, password:(nonnull NSString*)password token:(nonnull NSString*)token resetPasswordWithResolver:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject) {
    
    [[[NotificarePushLib shared] authManager] resetPassword:password withToken:token completionHandler:^(id  _Nullable response, NSError * _Nullable error) {
        if (!error) {
            resolve(nil);
        } else {
            reject(NOTIFICARE_ERROR, [error localizedDescription], error);
        }
    }];
    
}

RCT_REMAP_METHOD(sendPassword, email:(nonnull NSString*)email sendPasswordWithResolver:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject) {
    
    [[[NotificarePushLib shared] authManager] sendPassword:email completionHandler:^(id  _Nullable response, NSError * _Nullable error) {
        if (!error) {
            resolve(nil);
        } else {
            reject(NOTIFICARE_ERROR, [error localizedDescription], error);
        }
    }];
    
}

RCT_REMAP_METHOD(login, email:(nonnull NSString*)email password:(nonnull NSString*)password loginWithResolver:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject) {
    
    [[[NotificarePushLib shared] authManager] loginWithUsername:email andPassword:password completionHandler:^(id  _Nullable response, NSError * _Nullable error) {
        if (!error) {
            resolve(nil);
        } else {
            reject(NOTIFICARE_ERROR, [error localizedDescription], error);
        }
    }];
    
}

RCT_REMAP_METHOD(logout, logoutWithResolver:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject) {
    [[[NotificarePushLib shared] authManager] logoutAccount:^(id  _Nullable response, NSError * _Nullable error) {
          if (!error) {
              resolve(nil);
          } else {
              reject(NOTIFICARE_ERROR, [error localizedDescription], error);
          }
    }];
}

RCT_REMAP_METHOD(isLoggedIn, isLoggedInResolver:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject) {
    resolve(@([[[NotificarePushLib shared] authManager] isLoggedIn]));
}

RCT_REMAP_METHOD(generateAccessToken, generateAccessTokenWithResolver:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject) {
    
    [[[NotificarePushLib shared] authManager] generateAccessToken:^(id  _Nullable response, NSError * _Nullable error) {
        if (!error) {
            resolve([[NotificareReactNativeIOSUtils shared] dictionaryFromUser:response]);
        } else {
            reject(NOTIFICARE_ERROR, [error localizedDescription], error);
        }
    }];
    
}

RCT_REMAP_METHOD(changePassword, password:(nonnull NSString*)password changePasswordWithResolver:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject) {
    
    [[[NotificarePushLib shared] authManager] changePassword:password completionHandler:^(id  _Nullable response, NSError * _Nullable error) {
        if (!error) {
            resolve(nil);
        } else {
            reject(NOTIFICARE_ERROR, [error localizedDescription], error);
        }
    }];
    
}


RCT_REMAP_METHOD(fetchAccountDetails, fetchAccountDetailsWithResolver:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject) {
    
    [[[NotificarePushLib shared] authManager] fetchAccountDetails:^(id  _Nullable response, NSError * _Nullable error) {
        if (!error) {
            resolve([[NotificareReactNativeIOSUtils shared] dictionaryFromUser:response]);
        } else {
            reject(NOTIFICARE_ERROR, [error localizedDescription], error);
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
            reject(NOTIFICARE_ERROR, [error localizedDescription], error);
        }
    }];
    
}

RCT_REMAP_METHOD(addSegmentToUserPreference, segment:(nonnull NSDictionary*)segment userPreference:(nonnull NSDictionary*)userPreference addSegmentToUserPreferenceWithResolver:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject) {
    
    [[[NotificarePushLib shared] authManager] addSegment:[[NotificareReactNativeIOSUtils shared] segmentFromDictionary:segment] toPreference:[[NotificareReactNativeIOSUtils shared] userPreferenceFromDictionary:userPreference] completionHandler:^(id  _Nullable response, NSError * _Nullable error) {
        if (!error) {
            resolve(nil);
        } else {
            reject(NOTIFICARE_ERROR, [error localizedDescription], error);
        }
    }];
    
}

RCT_REMAP_METHOD(removeSegmentFromUserPreference, segment:(nonnull NSDictionary*)segment userPreference:(nonnull NSDictionary*)userPreference removeSegmentFromUserPreferenceWithResolver:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject) {
    
    [[[NotificarePushLib shared] authManager] removeSegment:[[NotificareReactNativeIOSUtils shared] segmentFromDictionary:segment] fromPreference:[[NotificareReactNativeIOSUtils shared] userPreferenceFromDictionary:userPreference] completionHandler:^(id  _Nullable response, NSError * _Nullable error) {
        if (!error) {
            resolve(nil);
        } else {
            reject(NOTIFICARE_ERROR, [error localizedDescription], error);
        }
    }];
    
}

RCT_EXPORT_METHOD(startScannableSessionWithQRCode){
    [[NotificarePushLib shared] startScannableSessionWithQRCode:[self navigationControllerForRootViewController] asModal:YES];
}

RCT_EXPORT_METHOD(presentScannable:(nonnull NSDictionary*)scannable) {
    
    dispatch_async(dispatch_get_main_queue(), ^{
        NotificareScannable * item = [[NotificareReactNativeIOSUtils shared] scannableFromDictionary:scannable];
        [[NotificarePushLib shared] openScannable:item completionHandler:^(id  _Nullable response, NSError * _Nullable error) {
            if (!error) {
                if ([self isViewController:response]) {
                    UINavigationController *navController = [self navigationControllerForViewControllers:response];
                    [[[[UIApplication sharedApplication] keyWindow] rootViewController] presentViewController:navController animated:YES completion:^{
                        [[NotificarePushLib shared] presentScannable:item inNavigationController:navController withController:response];
                    }];
                } else {
                    [[NotificarePushLib shared] presentScannable:item inNavigationController:[self navigationControllerForRootViewController] withController:response];
                }
            }
        }];
    });
    
}

RCT_EXPORT_METHOD(requestAlwaysAuthorizationForLocationUpdates) {
    [[NotificarePushLib shared] requestAlwaysAuthorizationForLocationUpdates];
}

RCT_EXPORT_METHOD(requestTemporaryFullAccuracyAuthorization: (nonnull NSString*) purposeKey) {
    if (@available(iOS 14.0, *)) {
        [[NotificarePushLib shared] requestTemporaryFullAccuracyAuthorizationWithPurposeKey:purposeKey];
    }
}

RCT_REMAP_METHOD(fetchLink, url:(nonnull NSString*)url fetchLinkWithResolver:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject) {
    NSURL* nsUrl = [NSURL URLWithString:url];

    [[NotificarePushLib shared] fetchLink:nsUrl completionHandler:^(id  _Nullable response, NSError * _Nullable error) {
        if (!error) {
            resolve([response absoluteString]);
        } else {
            reject(NOTIFICARE_ERROR, [error localizedDescription], error);
        }
    }];
}

@end
