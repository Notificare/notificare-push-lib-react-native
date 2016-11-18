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
#import "RCTUtils.h"

@implementation NotificareReactNativeIOS

@synthesize bridge = _bridge;

static NotificareReactNativeIOS *instance = nil;
static PushHandler *pushHandler = nil;

#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v) ([[[UIDevice currentDevice] systemVersion] compare:(v) options:NSNumericSearch] != NSOrderedAscending)

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
        NSMutableDictionary * theNotification = [NSMutableDictionary dictionaryWithDictionary:notification];

        if ([application applicationState] == UIApplicationStateActive) {
            [theNotification setObject:[NSNumber numberWithBool:YES] forKey:@"foreground"];
        } else {
            [theNotification setObject:[NSNumber numberWithBool:NO] forKey:@"foreground"];
        }
        
        [[NotificareReactNativeIOS getInstance] dispatchEvent:@"notificationReceived" body:theNotification];

      result(info);
    } errorHandler:^(NSError * _Nonnull error) {
      //
      errorBlock(error);
    }];
}

+ (void)registerDevice:(NSData *)deviceToken completionHandler:(SuccessBlock)result errorHandler:(ErrorBlock)errorBlock {
  
  [[NotificareReactNativeIOS getInstance] dispatchEvent:@"didReceiveDeviceToken" body:@{@"device": [deviceToken hexadecimalString]}];
    
    result(@{@"device" : [deviceToken hexadecimalString]});
  
}

+ (void)handleAction:(NSString *)identifier forNotification:(NSDictionary *)userInfo withData:(NSDictionary *)data completionHandler:(SuccessBlock)result errorHandler:(ErrorBlock)errorBlock{

    [[NotificarePushLib shared] handleAction:identifier forNotification:userInfo withData:data completionHandler:^(NSDictionary * _Nonnull info) {
        result(info);
    } errorHandler:^(NSError * _Nonnull error) {
        errorBlock(error);
    }];
}


+ (void)handleOpenURL:(NSURL *)url{
    
    [[NotificarePushLib shared] handleOpenURL:url];
    NSMutableDictionary * payload = [NSMutableDictionary new];
    [payload setObject:[url absoluteString] forKey:@"url"];
    [[NotificareReactNativeIOS getInstance] dispatchEvent:@"willOpenURL" body:payload];
    
}

- (NSArray<NSString*> *)supportedEvents {
    return @[@"notificationReceived", @"notificationOpened", @"ready", @"badge", @"systemPush", @"didLoadStore", @"didFailToLoadStore", @"didReceiveDeviceToken", @"willOpenURL", @"willOpenNotification", @"didOpenNotification", @"didClickURL", @"didCloseNotification", @"didFailToOpenNotification", @"willExecuteAction", @"didExecuteAction", @"shouldPerformSelectorWithURL", @"didNotExecuteAction", @"didFailToExecuteAction", @"didReceiveLocationServiceAuthorizationStatus", @"didFailToStartLocationServiceWithError", @"didUpdateLocations", @"monitoringDidFailForRegion", @"didDetermineState", @"didEnterRegion", @"didExitRegion", @"didStartMonitoringForRegion", @"rangingBeaconsDidFailForRegion", @"didRangeBeacons", @"didFailProductTransaction", @"didCompleteProductTransaction", @"didRestoreProductTransaction", @"didStartDownloadContent", @"didPauseDownloadContent", @"didCancelDownloadContent", @"didReceiveProgressDownloadContent", @"didFailDownloadContent", @"didFinishDownloadContent", @"didChangeAccountNotification", @"didFailToRequestAccessNotification", @"didValidateAccount", @"didFailToValidateAccount", @"didReceiveResetPasswordToken"];
}

- (dispatch_queue_t)methodQueue
{
  instance = self;
  return dispatch_get_main_queue();
}

- (void)dispatchEvent:(NSString *)event body:(NSDictionary *)notification {
  [self sendEventWithName:event body:notification];
}


/**
 * Helper method to convert SKDownload to NSDictionary
 */
-(NSDictionary *)dictionaryFromSKDownload:(SKDownload *)download{
    
    NSMutableDictionary * payload = [NSMutableDictionary dictionary];
    NSMutableDictionary * theDownload = [NSMutableDictionary dictionary];
    [theDownload setObject:[download contentIdentifier] forKey:@"contentIdentifier"];
    [theDownload setObject:[download contentURL] forKey:@"contentURL"];
    [theDownload setObject:[NSNumber numberWithLong:[download contentLength]] forKey:@"contentLength"];
    [theDownload setObject:[download contentVersion] forKey:@"contentVersion"];
    [theDownload setObject:[NSNumber numberWithInt:[download downloadState]] forKey:@"downloadState"];
    [theDownload setObject:[NSNumber numberWithFloat:[download progress]] forKey:@"progress"];
    [theDownload setObject:[NSNumber numberWithDouble:[download timeRemaining]] forKey:@"timeRemaining"];
    [payload setObject:theDownload forKey:@"download"];
    
    return payload;
}


/**
 * Helper method to convert NotificareProduct to NSDictionary
 */
-(NSDictionary *)dictionaryFromProduct:(NotificareProduct *)product{
    
    NSMutableDictionary * payload = [NSMutableDictionary new];
    [payload setObject:[product identifier] forKey:@"identifier"];
    [payload setObject:[product productName] forKey:@"productName"];
    [payload setObject:[product productDescription] forKey:@"productDescription"];
    [payload setObject:[product price] forKey:@"price"];
    [payload setObject:[product priceLocale] forKey:@"priceLocale"];
    [payload setObject:[product stores] forKey:@"stores"];
    
    NSMutableArray * downloads = [NSMutableArray array];
    for (SKDownload * d in [product downloads]) {
        [downloads addObject:[self dictionaryFromSKDownload:d]];
    }
    [payload setObject:downloads forKey:@"downloads"];
    
    
    return payload;
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

RCT_EXPORT_METHOD(stopLocationUpdates) {
    
    [[NotificarePushLib shared] stopLocationUpdates];
    
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
      callback(@[[NSNull null], info]);
    } errorHandler:^(NSError * _Nonnull error) {
      callback(@[RCTJSErrorFromNSError(error), [NSNull null]]);
    }];
    
  } else if (userID && !userName) {
    
    [[NotificarePushLib shared] registerDevice:token withUserID:userID completionHandler:^(NSDictionary * _Nonnull info) {
      callback(@[[NSNull null], info]);
    } errorHandler:^(NSError * _Nonnull error) {
      callback(@[RCTJSErrorFromNSError(error), [NSNull null]]);
    }];
    
  } else {
    
    [[NotificarePushLib shared] registerDevice:token completionHandler:^(NSDictionary * _Nonnull info) {
      callback(@[[NSNull null], info]);
    } errorHandler:^(NSError * _Nonnull error) {
      callback(@[RCTJSErrorFromNSError(error), [NSNull null]]);
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
    callback(@[RCTJSErrorFromNSError(error), [NSNull null]]);
  }];
  
}


RCT_EXPORT_METHOD(addTags:(NSArray *)tags callback:(RCTResponseSenderBlock)callback) {
  
  [[NotificarePushLib shared] addTags:tags completionHandler:^(NSDictionary * _Nonnull info) {
    callback(@[[NSNull null], info]);
  } errorHandler:^(NSError * _Nonnull error) {
    callback(@[RCTJSErrorFromNSError(error), [NSNull null]]);
  }];

}

RCT_EXPORT_METHOD(removeTag:(NSString *)tag callback:(RCTResponseSenderBlock)callback) {
  
  [[NotificarePushLib shared] removeTag:tag completionHandler:^(NSDictionary * _Nonnull info) {
    callback(@[[NSNull null], info]);
  } errorHandler:^(NSError * _Nonnull error) {
    callback(@[RCTJSErrorFromNSError(error), [NSNull null]]);
  }];
  
}

RCT_EXPORT_METHOD(clearTags:(RCTResponseSenderBlock)callback) {
  
  [[NotificarePushLib shared] clearTags:^(NSDictionary * _Nonnull info) {
    callback(@[[NSNull null], info]);
  } errorHandler:^(NSError * _Nonnull error) {
    callback(@[RCTJSErrorFromNSError(error), [NSNull null]]);
  }];
  
}


RCT_EXPORT_METHOD(openNotification:(NSDictionary *)notification) {
  
  [[NotificarePushLib shared] openNotification:notification];
  
}

RCT_EXPORT_METHOD(fetchInbox:(NSDate*)since skip:(NSNumber* _Nonnull)skip limit:(NSNumber* _Nonnull)limit callback:(RCTResponseSenderBlock)callback) {
  
  [[NotificarePushLib shared] fetchInbox:since skip:skip limit:limit completionHandler:^(NSDictionary * _Nonnull info) {
    
      NSMutableDictionary * payload = [NSMutableDictionary new];
    
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
    
      [payload setObject:items forKey:@"inbox"];
      [payload setObject:[NSNumber numberWithInt:[[info objectForKey:@"total"] intValue]] forKey:@"total"];
      [payload setObject:[NSNumber numberWithInt:[[info objectForKey:@"unread"] intValue]] forKey:@"unread"];
      callback(@[[NSNull null], payload]);
      
  } errorHandler:^(NSError * _Nonnull error) {
    callback(@[RCTJSErrorFromNSError(error), [NSNull null]]);
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
    callback(@[RCTJSErrorFromNSError(error), [NSNull null]]);
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
    callback(@[RCTJSErrorFromNSError(error), [NSNull null]]);
  }];
  
}


RCT_EXPORT_METHOD(clearInbox:(RCTResponseSenderBlock)callback) {
    
    [[NotificarePushLib shared] clearInbox:^(NSDictionary * _Nonnull info) {
        callback(@[[NSNull null], info]);
    } errorHandler:^(NSError * _Nonnull error) {
        callback(@[RCTJSErrorFromNSError(error), [NSNull null]]);
    }];
    
}


RCT_EXPORT_METHOD(fetchAssets:(NSString*)group callback:(RCTResponseSenderBlock)callback) {
    
    NSMutableDictionary * trans = [NSMutableDictionary dictionary];
    
    [[NotificarePushLib shared] fetchAssets:group completionHandler:^(NSArray *files) {
        
        NSMutableArray * assets = [NSMutableArray array];
        
        for (NotificareAsset * f in files) {
            
            NSMutableDictionary * file = [NSMutableDictionary dictionary];
            [file setValue:[f assetTitle] forKey:@"title"];
            [file setValue:[f assetDescription] forKey:@"description"];
            [file setValue:[f assetUrl] forKey:@"url"];
            [file setObject:[f assetMetaData] forKey:@"metaData"];
            [file setObject:[f assetButton] forKey:@"button"];
            [assets addObject:file];
            
        }
        
        [trans setObject:assets forKey:@"assets"];
        
       callback(@[[NSNull null], trans]);
        
    } errorHandler:^(NSError *error) {
        callback(@[RCTJSErrorFromNSError(error), [NSNull null]]);
    }];

}

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


RCT_EXPORT_METHOD(fetchDoNotDisturb:(RCTResponseSenderBlock)callback) {
    
    [[NotificarePushLib shared] fetchDoNotDisturb:^(NSDictionary * _Nonnull info) {
        callback(@[[NSNull null], info]);
    } errorHandler:^(NSError * _Nonnull error) {
        callback(@[RCTJSErrorFromNSError(error), [NSNull null]]);
    }];
    
}


RCT_EXPORT_METHOD(updateDoNotDisturb:(NSDate *)start endTime:(NSDate *)end callback:(RCTResponseSenderBlock)callback) {
    
    [[NotificarePushLib shared] updateDoNotDisturb:start endTime:end completionHandler:^(NSDictionary * _Nonnull info) {
        callback(@[[NSNull null], info]);
    } errorHandler:^(NSError * _Nonnull error) {
        callback(@[RCTJSErrorFromNSError(error), [NSNull null]]);
    }];
    
}


RCT_EXPORT_METHOD(clearDoNotDisturb:(RCTResponseSenderBlock)callback) {
    
    [[NotificarePushLib shared] clearDoNotDisturb:^(NSDictionary * _Nonnull info) {
        callback(@[[NSNull null], info]);
    } errorHandler:^(NSError * _Nonnull error) {
        callback(@[RCTJSErrorFromNSError(error), [NSNull null]]);
    }];
    
}


RCT_EXPORT_METHOD(fetchUserData:(RCTResponseSenderBlock)callback) {
    
    [[NotificarePushLib shared] fetchUserData:^(NSDictionary * _Nonnull info) {
        callback(@[[NSNull null], info]);
    } errorHandler:^(NSError * _Nonnull error) {
        callback(@[RCTJSErrorFromNSError(error), [NSNull null]]);
    }];
    
}


RCT_EXPORT_METHOD(updateUserData:(NSDictionary *)data callback:(RCTResponseSenderBlock)callback) {
    
    [[NotificarePushLib shared] updateUserData:data completionHandler:^(NSDictionary * _Nonnull info) {
        callback(@[[NSNull null], info]);
    } errorHandler:^(NSError * _Nonnull error) {
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



RCT_EXPORT_METHOD(fetchNotification:(NSDictionary *)notification callback:(RCTResponseSenderBlock)callback) {
    
    [[NotificarePushLib shared] getNotification:[notification objectForKey:@"id"] completionHandler:^(NSDictionary * _Nonnull info) {
        callback(@[[NSNull null], info]);
    } errorHandler:^(NSError * _Nonnull error) {
        callback(@[RCTJSErrorFromNSError(error), [NSNull null]]);
    }];
    
}

RCT_EXPORT_METHOD(clearNotification:(NSDictionary *)notification callback:(RCTResponseSenderBlock)callback) {
    
    [[NotificarePushLib shared] clearNotification:[notification objectForKey:@"id"]];
    callback(@[[NSNull null], notification]);
    
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

@end

/**
 *
 * Helper class to handle NotificarePushLib delegates
 *
 */
@implementation PushHandler

-(void)notificarePushLib:(NotificarePushLib *)library onReady:(NSDictionary *)info{

  [[NotificareReactNativeIOS getInstance] dispatchEvent:@"ready" body:info];
  
}

-(void)notificarePushLib:(NotificarePushLib *)library willHandleNotification:(UNNotification *)notification{
  
  [[NotificareReactNativeIOS getInstance] dispatchEvent:@"notificationOpened" body:notification.request.content.userInfo];
  
}

- (void)notificarePushLib:(NotificarePushLib *)library didReceiveSystemPush:(nonnull NSDictionary *)info{
  [[NotificareReactNativeIOS getInstance] dispatchEvent:@"systemPush" body:info];
}

-(void)notificarePushLib:(NotificarePushLib *)library didUpdateBadge:(int)badge{
  
  NSMutableDictionary * info = [NSMutableDictionary new];
  [info setObject:[NSNumber numberWithInt:badge] forKey:@"badge"];
  [[NotificareReactNativeIOS getInstance] dispatchEvent:@"badge" body:info];
  
}


- (void)notificarePushLib:(NotificarePushLib *)library willOpenNotification:(NotificareNotification *)notification{
    
    [[NotificareReactNativeIOS getInstance] dispatchEvent:@"willOpenNotification" body:[self dictionaryFromNotification:notification]];
    
}

- (void)notificarePushLib:(NotificarePushLib *)library didOpenNotification:(NotificareNotification *)notification{
    
    [[NotificareReactNativeIOS getInstance] dispatchEvent:@"didOpenNotification" body:[self dictionaryFromNotification:notification]];

}

- (void)notificarePushLib:(NotificarePushLib *)library didClickURL:(NSURL *)url inNotification:(NotificareNotification *)notification{

    NSMutableDictionary * payload = [NSMutableDictionary dictionaryWithDictionary:[self dictionaryFromNotification:notification]];
    [payload setObject:[url absoluteString] forKey:@"url"];
    
    [[NotificareReactNativeIOS getInstance] dispatchEvent:@"didClickURL" body:payload];
}

- (void)notificarePushLib:(NotificarePushLib *)library didCloseNotification:(NotificareNotification *)notification{
 
    [[NotificareReactNativeIOS getInstance] dispatchEvent:@"didCloseNotification" body:[self dictionaryFromNotification:notification]];
    
}

- (void)notificarePushLib:(NotificarePushLib *)library didFailToOpenNotification:(NotificareNotification *)notification{

    [[NotificareReactNativeIOS getInstance] dispatchEvent:@"didFailToOpenNotification" body:[self dictionaryFromNotification:notification]];

}


- (void)notificarePushLib:(NotificarePushLib *)library willExecuteAction:(NotificareNotification *)notification{
    
    [[NotificareReactNativeIOS getInstance] dispatchEvent:@"willExecuteAction" body:[self dictionaryFromNotification:notification]];
}

- (void)notificarePushLib:(NotificarePushLib *)library didExecuteAction:(NSDictionary *)info{

}


-(void)notificarePushLib:(NotificarePushLib *)library shouldPerformSelectorWithURL:(NSURL *)url{
    
    NSMutableDictionary * payload = [NSMutableDictionary new];
    [payload setObject:[url absoluteString] forKey:@"url"];
    
    [[NotificareReactNativeIOS getInstance] dispatchEvent:@"shouldPerformSelectorWithURL" body:payload];
}

- (void)notificarePushLib:(NotificarePushLib *)library didNotExecuteAction:(NSDictionary *)info{

    [[NotificareReactNativeIOS getInstance] dispatchEvent:@"didNotExecuteAction" body:info];
    
}

- (void)notificarePushLib:(NotificarePushLib *)library didFailToExecuteAction:(NSError *)error{

    [[NotificareReactNativeIOS getInstance] dispatchEvent:@"didFailToExecuteAction" body:@{@"error" : [error localizedDescription]}];
    
}


#pragma Notificare Location delegates
- (void)notificarePushLib:(NotificarePushLib *)library didReceiveLocationServiceAuthorizationStatus:(NSDictionary *)status{

    [[NotificareReactNativeIOS getInstance] dispatchEvent:@"didReceiveLocationServiceAuthorizationStatus" body:status];
    
}

- (void)notificarePushLib:(NotificarePushLib *)library didFailToStartLocationServiceWithError:(NSError *)error{

    [[NotificareReactNativeIOS getInstance] dispatchEvent:@"didFailToStartLocationServiceWithError" body:@{@"error" : [error localizedDescription]}];
    
}

- (void)notificarePushLib:(NotificarePushLib *)library didUpdateLocations:(NSArray *)locations{
    
    CLLocation * lastLocation = (CLLocation *)[locations lastObject];
    NSMutableDictionary * location = [NSMutableDictionary dictionary];
    [location setValue:[NSNumber numberWithFloat:[lastLocation coordinate].latitude] forKey:@"latitude"];
    [location setValue:[NSNumber numberWithFloat:[lastLocation coordinate].longitude] forKey:@"longitude"];
    [[NotificareReactNativeIOS getInstance] dispatchEvent:@"didUpdateLocations" body:location];
    
}

- (void)notificarePushLib:(NotificarePushLib *)library monitoringDidFailForRegion:(CLRegion *)region withError:(NSError *)error{
 
    NSMutableDictionary * payload = [NSMutableDictionary dictionary];
    [payload setObject:[region identifier] forKey:@"region"];
    [payload setObject:[error localizedDescription] forKey:@"error"];
    
    [[NotificareReactNativeIOS getInstance] dispatchEvent:@"monitoringDidFailForRegion" body:payload];
    
}


- (void)notificarePushLib:(NotificarePushLib *)library didDetermineState:(CLRegionState)state forRegion:(CLRegion *)region{
    
    NSMutableDictionary * payload = [NSMutableDictionary dictionary];
    [payload setObject:[region identifier] forKey:@"region"];
    [payload setObject:[NSNumber numberWithInt:state] forKey:@"state"];
    
    [[NotificareReactNativeIOS getInstance] dispatchEvent:@"didDetermineState" body:payload];
    
}


- (void)notificarePushLib:(NotificarePushLib *)library didEnterRegion:(CLRegion *)region{
    
    NSMutableDictionary * payload = [NSMutableDictionary dictionary];
    [payload setObject:[region identifier] forKey:@"region"];;
    
    [[NotificareReactNativeIOS getInstance] dispatchEvent:@"didEnterRegion" body:payload];
    
}



- (void)notificarePushLib:(NotificarePushLib *)library didExitRegion:(CLRegion *)region{
    
    NSMutableDictionary * payload = [NSMutableDictionary dictionary];
    [payload setObject:[region identifier] forKey:@"region"];;
    
    [[NotificareReactNativeIOS getInstance] dispatchEvent:@"didExitRegion" body:payload];
    
}


- (void)notificarePushLib:(NotificarePushLib *)library didStartMonitoringForRegion:(CLRegion *)region{

    NSMutableDictionary * payload = [NSMutableDictionary dictionary];
    [payload setObject:[region identifier] forKey:@"region"];;
    
    [[NotificareReactNativeIOS getInstance] dispatchEvent:@"didStartMonitoringForRegion" body:payload];
    
}


- (void)notificarePushLib:(NotificarePushLib *)library rangingBeaconsDidFailForRegion:(CLBeaconRegion *)region withError:(NSError *)error{
    
    NSMutableDictionary * payload = [NSMutableDictionary dictionary];
    [payload setObject:[region identifier] forKey:@"region"];
    [payload setObject:[error localizedDescription] forKey:@"error"];
    
    [[NotificareReactNativeIOS getInstance] dispatchEvent:@"rangingBeaconsDidFailForRegion" body:payload];
    
}

- (void)notificarePushLib:(NotificarePushLib *)library didRangeBeacons:(NSArray *)beacons inRegion:(CLBeaconRegion *)region{
    
    NSMutableDictionary * payload = [NSMutableDictionary dictionary];
    NSMutableArray * theBeacons = [NSMutableArray array];
    
    [payload setObject:[region identifier] forKey:@"region"];
    
    for (NotificareBeacon * beacon in beacons) {
        NSMutableDictionary * b = [NSMutableDictionary dictionary];
        [b setObject:[[beacon beaconUUID] UUIDString] forKey:@"uuid"];
        [b setObject:[beacon major] forKey:@"major"];
        [b setObject:[beacon minor] forKey:@"minor"];
        [b setObject:[beacon notification] forKey:@"notification"];
        [b setObject:[NSNumber numberWithInt:[[beacon beacon] proximity]] forKey:@"proximity"];
        [theBeacons addObject:b];
    }
    
    [payload setObject:theBeacons forKey:@"beacons"];
    
    [[NotificareReactNativeIOS getInstance] dispatchEvent:@"didRangeBeacons" body:payload];
    
}


#pragma Notificare In-App Purchases

- (void)notificarePushLib:(NotificarePushLib *)library didLoadStore:(NSArray *)products{
    
    NSMutableDictionary * payload = [NSMutableDictionary dictionary];
    NSMutableArray * prods = [NSMutableArray new];
    
    for (NotificareProduct * product in products) {
        [prods addObject:[self dictionaryFromProduct:product]];
    }
    
    [payload setObject:prods forKey:@"products"];
    
    [[NotificareReactNativeIOS getInstance] dispatchEvent:@"didLoadStore" body:payload];
    
}


- (void)notificarePushLib:(NotificarePushLib *)library didFailToLoadStore:(NSError *)error{
    
    [[NotificareReactNativeIOS getInstance] dispatchEvent:@"didFailToLoadStore" body:@{@"products": @[]}];
    
}

- (void)notificarePushLib:(NotificarePushLib *)library didFailProductTransaction:(SKPaymentTransaction *)transaction withError:(NSError *)error{

    NSMutableDictionary * payload = [NSMutableDictionary dictionary];
    [payload setObject:[transaction transactionIdentifier] forKey:@"transaction"];
    [payload setObject:[error localizedDescription] forKey:@"error"];
    
    [[NotificareReactNativeIOS getInstance] dispatchEvent:@"didFailProductTransaction" body:payload];
}


- (void)notificarePushLib:(NotificarePushLib *)library didCompleteProductTransaction:(SKPaymentTransaction *)transaction{
    
    NSMutableDictionary * payload = [NSMutableDictionary dictionary];
    [payload setObject:[transaction transactionIdentifier] forKey:@"transaction"];
    
    [[NotificareReactNativeIOS getInstance] dispatchEvent:@"didCompleteProductTransaction" body:payload];
}


- (void)notificarePushLib:(NotificarePushLib *)library didRestoreProductTransaction:(SKPaymentTransaction *)transaction{

    NSMutableDictionary * payload = [NSMutableDictionary dictionary];
    [payload setObject:[transaction transactionIdentifier] forKey:@"transaction"];
    
    [[NotificareReactNativeIOS getInstance] dispatchEvent:@"didRestoreProductTransaction" body:payload];
    
}


- (void)notificarePushLib:(NotificarePushLib *)library didStartDownloadContent:(SKPaymentTransaction *)transaction{
    
    NSMutableDictionary * payload = [NSMutableDictionary dictionary];
    [payload setObject:[transaction transactionIdentifier] forKey:@"transaction"];
    
    [[NotificareReactNativeIOS getInstance] dispatchEvent:@"didStartDownloadContent" body:payload];
    
}


- (void)notificarePushLib:(NotificarePushLib *)library didPauseDownloadContent:(SKDownload *)download{
    
    [[NotificareReactNativeIOS getInstance] dispatchEvent:@"didPauseDownloadContent" body:[self dictionaryFromSKDownload:download]];

}


- (void)notificarePushLib:(NotificarePushLib *)library didCancelDownloadContent:(SKDownload *)download{
    
    [[NotificareReactNativeIOS getInstance] dispatchEvent:@"didCancelDownloadContent" body:[self dictionaryFromSKDownload:download]];

}


- (void)notificarePushLib:(NotificarePushLib *)library didReceiveProgressDownloadContent:(SKDownload *)download{
    
    [[NotificareReactNativeIOS getInstance] dispatchEvent:@"didReceiveProgressDownloadContent" body:[self dictionaryFromSKDownload:download]];
}


- (void)notificarePushLib:(NotificarePushLib *)library didFailDownloadContent:(SKDownload *)download{
    
    [[NotificareReactNativeIOS getInstance] dispatchEvent:@"didFailDownloadContent" body:[self dictionaryFromSKDownload:download]];
}


- (void)notificarePushLib:(NotificarePushLib *)library didFinishDownloadContent:(SKDownload *)download{
    
    [[NotificareReactNativeIOS getInstance] dispatchEvent:@"didFinishDownloadContent" body:[self dictionaryFromSKDownload:download]];
}


#pragma Notificare OAuth2 delegates

- (void)notificarePushLib:(NotificarePushLib *)library didChangeAccountNotification:(NSDictionary *)info{
    [[NotificareReactNativeIOS getInstance] dispatchEvent:@"didChangeAccountNotification" body:info];
}

- (void)notificarePushLib:(NotificarePushLib *)library didFailToRequestAccessNotification:(NSError *)error{
    
    [[NotificareReactNativeIOS getInstance] dispatchEvent:@"didFailToRequestAccessNotification" body:RCTJSErrorFromNSError(error)];
}


- (void)notificarePushLib:(NotificarePushLib *)library didReceiveActivationToken:(NSString *)token{
    
    [[NotificarePushLib shared] validateAccount:token completionHandler:^(NSDictionary *info) {
        
        [[NotificareReactNativeIOS getInstance] dispatchEvent:@"didValidateAccount" body:info];
        
    } errorHandler:^(NSError *error) {
        
        [[NotificareReactNativeIOS getInstance] dispatchEvent:@"didFailToValidateAccount" body:RCTJSErrorFromNSError(error)];
        
    }];
    
}

- (void)notificarePushLib:(NotificarePushLib *)library didReceiveResetPasswordToken:(NSString *)token{
    
    [[NotificareReactNativeIOS getInstance] dispatchEvent:@"didReceiveResetPasswordToken" body:@{@"token": token}];
}


/**
 * Helper method to convert NotificareNotification to a dictionary
 **/
-(NSDictionary *)dictionaryFromNotification:(NotificareNotification *)notification{
    NSMutableDictionary * message = [NSMutableDictionary dictionary];
    NSMutableDictionary * trans = [NSMutableDictionary dictionary];
    [trans setValue:[notification notificationID] forKey:@"id"];
    [trans setValue:[notification notificationType] forKey:@"type"];
    [trans setValue:[notification notificationTime] forKey:@"time"];
    [trans setValue:[notification notificationMessage] forKey:@"message"];
    
    if([notification notificationExtra]){
        [trans setObject:[notification notificationExtra] forKey:@"extra"];
    }
    
    [trans setObject:[notification notificationInfo] forKey:@"info"];
    [trans setObject:[notification notificationTags] forKey:@"tags"];
    [trans setObject:[notification notificationSegments] forKey:@"segments"];
    
    if([notification notificationLatitude] && [notification notificationLongitude] && [notification notificationDistance]){
        
        NSMutableDictionary * location = [NSMutableDictionary dictionary];
        [location setValue:[notification notificationLatitude] forKey:@"latitude"];
        [location setValue:[notification notificationLongitude] forKey:@"longitude"];
        [location setValue:[notification notificationDistance] forKey:@"distance"];
        [trans setObject:location forKey:@"location"];
        
    }
    
    NSMutableArray * content = [NSMutableArray array];
    for (NotificareContent * c in [notification notificationContent]) {
        NSMutableDictionary * cont = [NSMutableDictionary dictionary];
        [cont setObject:[c type] forKey:@"type"];
        [cont setObject:[c data] forKey:@"data"];
        [content addObject:cont];
    }
    [trans setObject:content forKey:@"content"];
    
    NSMutableArray * actions = [NSMutableArray array];
    for (NotificareAction * a in [notification notificationActions]) {
        NSMutableDictionary * act = [NSMutableDictionary dictionary];
        [act setValue:[a actionLabel] forKey:@"label"];
        [act setValue:[a actionType] forKey:@"type"];
        [act setValue:[a actionTarget] forKey:@"type"];
        [act setObject:[NSNumber numberWithBool:[a actionCamera]] forKey:@"camera"];
        [act setObject:[NSNumber numberWithBool:[a actionKeyboard]] forKey:@"keyboard"];
        [actions addObject:act];
    }
    [trans setObject:actions forKey:@"actions"];
    
    
    [message setObject:trans forKey:@"notification"];
    
    return message;
}

/**
 * Helper method to convert SKDownload to NSDictionary
 */
-(NSDictionary *)dictionaryFromSKDownload:(SKDownload *)download{

    NSMutableDictionary * payload = [NSMutableDictionary dictionary];
    NSMutableDictionary * theDownload = [NSMutableDictionary dictionary];
    [theDownload setObject:[download contentIdentifier] forKey:@"contentIdentifier"];
    [theDownload setObject:[download contentURL] forKey:@"contentURL"];
    [theDownload setObject:[NSNumber numberWithLong:[download contentLength]] forKey:@"contentLength"];
    [theDownload setObject:[download contentVersion] forKey:@"contentVersion"];
    [theDownload setObject:[NSNumber numberWithInt:[download downloadState]] forKey:@"downloadState"];
    [theDownload setObject:[NSNumber numberWithFloat:[download progress]] forKey:@"progress"];
    [theDownload setObject:[NSNumber numberWithDouble:[download timeRemaining]] forKey:@"timeRemaining"];
    [payload setObject:theDownload forKey:@"download"];
    
    return payload;
}


/**
 * Helper method to convert NotificareProduct to NSDictionary
 */
-(NSDictionary *)dictionaryFromProduct:(NotificareProduct *)product{
    
    NSMutableDictionary * payload = [NSMutableDictionary new];
    [payload setObject:[product identifier] forKey:@"identifier"];
    [payload setObject:[product productName] forKey:@"productName"];
    [payload setObject:[product productDescription] forKey:@"productDescription"];
    [payload setObject:[product price] forKey:@"price"];
    [payload setObject:[product priceLocale] forKey:@"priceLocale"];
    [payload setObject:[product stores] forKey:@"stores"];
    
    NSMutableArray * downloads = [NSMutableArray array];
    for (SKDownload * d in [product downloads]) {
        [downloads addObject:[self dictionaryFromSKDownload:d]];
    }
    [payload setObject:downloads forKey:@"downloads"];
    
    
    return payload;
}

@end
