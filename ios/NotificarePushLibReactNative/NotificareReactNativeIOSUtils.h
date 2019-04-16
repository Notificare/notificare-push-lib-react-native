//
//  NotificarereactNativeIOSUtils.h
//  NotificarePushLibReactNative
//
//  Created by Joel Oliveira on 16/04/2019.
//  Copyright © 2019 Notificare. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "../Libraries/NotificarePushLib/NotificarePushLib.h"

NS_ASSUME_NONNULL_BEGIN

@interface NotificareReactNativeIOSUtils : NSObject

+ (NotificareReactNativeIOSUtils *)shared;

-(NSDictionary *)dictionaryFromApplication:(NotificareApplication *)application;

-(NSDictionary *)dictionaryFromDevice:(NotificareDevice *)device;

-(NSDictionary *)dictionaryFromUserData:(NotificareUserData *)userData;
-(NotificareUserData *)userDataFromDictionary:(NSDictionary *)dictionary;

-(NSDictionary *)dictionaryFromDeviceDnD:(NotificareDeviceDnD *)deviceDnD;
-(NotificareDeviceDnD *)deviceDnDFromDictionary:(NSDictionary *)dictionary;

-(NSDictionary *)dictionaryFromNotification:(NotificareNotification *)notification;
-(NotificareNotification *)notificationFromDictionary:(NSDictionary *)dictionary;

-(NSDictionary *)dictionaryFromAction:(NotificareAction *)action;
-(NotificareAction *)actionFromDictionary:(NSDictionary *)dictionary;

-(NSDictionary *)dictionaryFromDeviceInbox:(NotificareDeviceInbox *)deviceInbox;
-(NotificareDeviceInbox *)deviceInboxFromDictionary:(NSDictionary *)dictionary;

-(NSDictionary *)dictionaryFromAsset:(NotificareAsset *)asset;

@end

NS_ASSUME_NONNULL_END
