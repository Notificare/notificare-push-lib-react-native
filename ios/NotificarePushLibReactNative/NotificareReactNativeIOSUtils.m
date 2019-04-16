//
//  NotificarereactNativeIOSUtils.m
//  NotificarePushLibReactNative
//
//  Created by Joel Oliveira on 16/04/2019.
//  Copyright © 2019 Notificare. All rights reserved.
//

#import "NotificareReactNativeIOSUtils.h"

@implementation NotificareReactNativeIOSUtils


static NotificareReactNativeIOSUtils *utils;

+ (void)load {
    utils = [[NotificareReactNativeIOSUtils alloc] init];
}

+ (NotificareReactNativeIOSUtils *)shared {
    return utils;
}

-(NSDictionary *)dictionaryFromApplication:(NotificareApplication *)application{
    NSMutableDictionary * data = [NSMutableDictionary dictionary];
    [data setValue:[application application] forKey:@"application"];
    [data setValue:[application name] forKey:@"name"];
    [data setValue:[application actionCategories] forKey:@"actionCategories"];
    [data setValue:[application appStoreId] forKey:@"appStoreId"];
    [data setValue:[application category] forKey:@"category"];
    [data setValue:[application inboxConfig] forKey:@"inboxConfig"];
    [data setValue:[application passbookConfig] forKey:@"passbookConfig"];
    [data setValue:[application regionConfig] forKey:@"regionConfig"];
    [data setValue:[application services] forKey:@"services"];
    [data setValue:[application websitePushConfig] forKey:@"websitePushConfig"];
    [data setValue:[application userDataFields] forKey:@"userDataFields"];
    return data;
}

-(NSDictionary *)dictionaryFromDevice:(NotificareDevice *)device{
    NSMutableDictionary * data = [NSMutableDictionary dictionary];
    [data setValue:[device deviceTokenData] forKey:@"deviceTokenData"];
    [data setValue:[device deviceID] forKey:@"deviceID"];
    [data setValue:[device userID] forKey:@"userID"];
    [data setValue:[device userName] forKey:@"userName"];
    [data setValue:[device timezone] forKey:@"timezone"];
    [data setValue:[device osVersion] forKey:@"osVersion"];
    [data setValue:[device sdkVersion] forKey:@"sdkVersion"];
    [data setValue:[device appVersion] forKey:@"appVersion"];
    [data setValue:[device country] forKey:@"country"];
    [data setValue:[device countryCode] forKey:@"countryCode"];
    [data setValue:[device language] forKey:@"language"];
    [data setValue:[device region] forKey:@"region"];
    [data setValue:[device transport] forKey:@"transport"];
    [data setValue:[device dnd] forKey:@"dnd"];
    [data setValue:[device userData] forKey:@"userData"];
    [data setValue:[device latitude] forKey:@"latitude"];
    [data setValue:[device longitude] forKey:@"longitude"];
    [data setValue:[device altitude] forKey:@"altitude"];
    [data setValue:[device floor] forKey:@"floor"];
    [data setValue:[device course] forKey:@"course"];
    [data setValue:[device lastRegistered] forKey:@"lastRegistered"];
    [data setValue:[device locationServicesAuthStatus] forKey:@"locationServicesAuthStatus"];
    [data setValue:[NSNumber numberWithBool:[device registeredForNotifications]] forKey:@"registeredForNotifications"];
    [data setValue:[NSNumber numberWithBool:[device allowedLocationServices]] forKey:@"allowedLocationServices"];
    [data setValue:[NSNumber numberWithBool:[device allowedUI]] forKey:@"allowedUI"];
    [data setValue:[NSNumber numberWithBool:[device backgroundAppRefresh]] forKey:@"backgroundAppRefresh"];
    [data setValue:[NSNumber numberWithBool:[device bluetoothON]] forKey:@"bluetoothON"];
    return data;
}

-(NSDictionary *)dictionaryFromUserData:(NotificareUserData *)userData{
    NSMutableDictionary * data = [NSMutableDictionary dictionary];
    [data setValue:[userData key] forKey:@"key"];
    [data setValue:[userData label] forKey:@"label"];
    [data setValue:[userData type] forKey:@"type"];
    [data setValue:[userData value] forKey:@"value"];
    return data;
}

-(NotificareUserData *)userDataFromDictionary:(NSDictionary *)dictionary{
    NotificareUserData * userData = [NotificareUserData new];
    [userData setKey:[dictionary objectForKey:@"key"]];
    [userData setValue:[dictionary objectForKey:@"value"]];
    [userData setType:[dictionary objectForKey:@"type"]];
    [userData setLabel:[dictionary objectForKey:@"label"]];
    return userData;
}

-(NSDictionary *)dictionaryFromDeviceDnD:(NotificareDeviceDnD *)deviceDnD{
    NSMutableDictionary * data = [NSMutableDictionary dictionary];
    if ([deviceDnD start]) {
        [data setValue:[deviceDnD start] forKey:@"start"];
    } else {
        [data setValue:[NSNull null] forKey:@"start"];
    }
    if ([deviceDnD end]) {
        [data setValue:[deviceDnD end] forKey:@"end"];
    } else {
        [data setValue:[NSNull null] forKey:@"end"];
    }

    return data;
}

-(NotificareDeviceDnD *)deviceDnDFromDictionary:(NSDictionary *)dictionary{
    
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"HH:mm"];
    
    NotificareDeviceDnD * deviceDnD = [NotificareDeviceDnD new];
    if ([dictionary objectForKey:@"start"]){
        [deviceDnD setStart:[dateFormat dateFromString:[dictionary objectForKey:@"start"]]];
    }
    if ([dictionary objectForKey:@"end"]){
        [deviceDnD setEnd:[dateFormat dateFromString:[dictionary objectForKey:@"end"]]];
    }
    return deviceDnD;
}

-(NSDictionary *)dictionaryFromNotification:(NotificareNotification *)notification{
    NSMutableDictionary * data = [NSMutableDictionary dictionary];
    [data setValue:[notification notificationID] forKey:@"id"];
    [data setValue:[notification application] forKey:@"application"];
    [data setValue:[notification notificationType] forKey:@"type"];
    [data setValue:[notification notificationTime] forKey:@"time"];
    [data setValue:[notification notificationTitle] forKey:@"title"];
    [data setValue:[notification notificationSubtitle] forKey:@"subtitle"];
    [data setValue:[notification notificationMessage] forKey:@"message"];
    
    if([notification notificationExtra]){
        [data setObject:[notification notificationExtra] forKey:@"extra"];
    }
    
    if([notification notificationInfo]){
        [data setObject:[notification notificationInfo] forKey:@"info"];
    }
    
    NSMutableArray * content = [NSMutableArray array];
    for (NotificareContent * c in [notification notificationContent]) {
        NSMutableDictionary * cont = [NSMutableDictionary dictionary];
        [cont setObject:[c type] forKey:@"type"];
        if ([c dataDictionary]) {
            [cont setObject:[c dataDictionary] forKey:@"data"];
        } else {
            [cont setObject:[c data] forKey:@"data"];
        }
        [content addObject:cont];
    }
    [data setObject:content forKey:@"content"];
    
    NSMutableArray * actions = [NSMutableArray array];
    for (NotificareAction * a in [notification notificationActions]) {
        NSMutableDictionary * act = [NSMutableDictionary dictionary];
        [act setValue:[a actionLabel] forKey:@"label"];
        [act setValue:[a actionType] forKey:@"type"];
        [act setValue:[a actionTarget] forKey:@"target"];
        [act setObject:[NSNumber numberWithBool:[a actionCamera]] forKey:@"camera"];
        [act setObject:[NSNumber numberWithBool:[a actionKeyboard]] forKey:@"keyboard"];
        [actions addObject:act];
    }
    [data setObject:actions forKey:@"actions"];
    
    
    NSMutableArray * attachments = [NSMutableArray array];
    for (NotificareAttachment * at in [notification notificationAttachments]) {
        NSMutableDictionary * att = [NSMutableDictionary dictionary];
        [att setValue:[at attachmentURI] forKey:@"uri"];
        [att setValue:[at attachmentMimeType] forKey:@"mimeType"];
        [attachments addObject:att];
    }
    [data setObject:attachments forKey:@"attachments"];
    
    return data;
}

-(NotificareNotification *)notificationFromDictionary:(NSDictionary *)dictionary{
    NotificareNotification * notification = [NotificareNotification new];
    [notification setNotificationID:[dictionary objectForKey:@"id"]];
    [notification setApplication:[dictionary objectForKey:@"application"]];
    [notification setNotificationType:[dictionary objectForKey:@"type"]];
    [notification setNotificationTime:[dictionary objectForKey:@"time"]];
    [notification setNotificationTitle:[dictionary objectForKey:@"title"]];
    [notification setNotificationSubtitle:[dictionary objectForKey:@"subtitle"]];
    [notification setNotificationMessage:[dictionary objectForKey:@"message"]];
    
    if ([dictionary objectForKey:@"extra"]) {
        [notification setNotificationExtra:[dictionary objectForKey:@"extra"]];
    }
    
    if ([dictionary objectForKey:@"info"]) {
        [notification setNotificationInfo:[dictionary objectForKey:@"info"]];
    }
    
    NSMutableArray * content = [NSMutableArray array];
    if ([dictionary objectForKey:@"content"] && [[dictionary objectForKey:@"content"] length] > 0) {
        for (NSDictionary *c in [dictionary objectForKey:@"content"]) {
            NotificareContent * cnt = [NotificareContent new];
            [cnt setType:[c objectForKey:@"type"]];
            if ([[c objectForKey:@"data"] isKindOfClass:[NSDictionary class]]) {
                [cnt setDataDictionary:[c objectForKey:@"data"]];
            } else {
                [cnt setData:[c objectForKey:@"data"]];
            }
            [content addObject:cnt];
        }
    }
    [notification setNotificationContent:content];
    
    NSMutableArray * actions = [NSMutableArray array];
    if ([dictionary objectForKey:@"actions"] && [[dictionary objectForKey:@"actions"] length] > 0) {
        for (NSDictionary *a in [dictionary objectForKey:@"actions"]) {
            NotificareAction * act = [NotificareAction new];
            [act setActionLabel:[a objectForKey:@"label"]];
            [act setActionType:[a objectForKey:@"type"]];
            [act setActionTarget:[a objectForKey:@"target"]];
            [act setActionKeyboard:[[a objectForKey:@"keyboard"] boolValue]];
            [act setActionCamera:[[a objectForKey:@"camera"] boolValue]];
            [actions addObject:act];
        }
    }
    [notification setNotificationActions:actions];
    
    NSMutableArray * attachments = [NSMutableArray array];
    if ([dictionary objectForKey:@"attachments"] && [[dictionary objectForKey:@"attachments"] length] > 0) {
        for (NSDictionary *at in [dictionary objectForKey:@"actions"]) {
            NotificareAttachment * att = [NotificareAttachment new];
            [att setAttachmentURI:[at objectForKey:@"uri"]];
            [att setAttachmentMimeType:[at objectForKey:@"mimeType"]];
            [attachments addObject:att];
        }
    }
    [notification setNotificationAttachments:attachments];
    
    return notification;
}

-(NSDictionary *)dictionaryFromAction:(NotificareAction *)action{
    NSMutableDictionary * act = [NSMutableDictionary dictionary];
    [act setValue:[action actionLabel] forKey:@"label"];
    [act setValue:[action actionType] forKey:@"type"];
    [act setValue:[action actionTarget] forKey:@"target"];
    [act setObject:[NSNumber numberWithBool:[action actionCamera]] forKey:@"camera"];
    [act setObject:[NSNumber numberWithBool:[action actionKeyboard]] forKey:@"keyboard"];
    return act;
}

-(NotificareAction *)actionFromDictionary:(NSDictionary *)dictionary{
    NotificareAction * action = [NotificareAction new];
    [action setActionLabel:[dictionary objectForKey:@"label"]];
    [action setActionType:[dictionary objectForKey:@"type"]];
    [action setActionTarget:[dictionary objectForKey:@"target"]];
    [action setActionKeyboard:[[dictionary objectForKey:@"keyboard"] boolValue]];
    [action setActionCamera:[[dictionary objectForKey:@"camera"] boolValue]];
    return action;
}

-(NSDictionary *)dictionaryFromDeviceInbox:(NotificareDeviceInbox *)deviceInbox{
    NSMutableDictionary * data = [NSMutableDictionary dictionary];
    [data setValue:[deviceInbox inboxId] forKey:@"inboxId"];
    [data setValue:[deviceInbox applicationId] forKey:@"applicationId"];
    [data setValue:[deviceInbox data] forKey:@"data"];
    [data setValue:[deviceInbox title] forKey:@"title"];
    [data setValue:[deviceInbox subtitle] forKey:@"subtitle"];
    [data setValue:[deviceInbox message] forKey:@"message"];
    [data setValue:[deviceInbox attachment] forKey:@"attachment"];
    [data setValue:[deviceInbox extra] forKey:@"extra"];
    [data setValue:[deviceInbox notification] forKey:@"notification"];
    [data setValue:[deviceInbox time] forKey:@"time"];
    [data setValue:[deviceInbox deviceID] forKey:@"deviceID"];
    [data setValue:[deviceInbox userID] forKey:@"userID"];
    [data setObject:[NSNumber numberWithBool:[deviceInbox opened]] forKey:@"opened"];
    return data;
}

-(NotificareDeviceInbox *)deviceInboxFromDictionary:(NSDictionary *)dictionary{
    NotificareDeviceInbox * inboxItem = [NotificareDeviceInbox new];
    [inboxItem setInboxId:[dictionary objectForKey:@"inboxId"]];
    [inboxItem setApplicationId:[dictionary objectForKey:@"applicationId"]];
    [inboxItem setTitle:[dictionary objectForKey:@"title"]];
    [inboxItem setSubtitle:[dictionary objectForKey:@"subtitle"]];
    [inboxItem setMessage:[dictionary objectForKey:@"message"]];
    [inboxItem setNotification:[dictionary objectForKey:@"notification"]];
    [inboxItem setTime:[dictionary objectForKey:@"time"]];
    if ([dictionary objectForKey:@"attachment"]) {
        [inboxItem setAttachment:[dictionary objectForKey:@"attachment"]];
    }
    if ([dictionary objectForKey:@"extra"]) {
        [inboxItem setAttachment:[dictionary objectForKey:@"extra"]];
    }
    if ([dictionary objectForKey:@"data"]) {
        [inboxItem setData:[dictionary objectForKey:@"data"]];
    }
    if ([dictionary objectForKey:@"deviceID"]) {
        [inboxItem setDeviceID:[dictionary objectForKey:@"deviceID"]];
    }
    if ([dictionary objectForKey:@"userID"]) {
        [inboxItem setUserID:[dictionary objectForKey:@"userID"]];
    }
    [inboxItem setOpened:[[dictionary objectForKey:@"opened"] boolValue]];
    return inboxItem;
}

-(NSDictionary *)dictionaryFromAsset:(NotificareAsset *)asset{
    NSMutableDictionary * data = [NSMutableDictionary dictionary];
    [data setValue:[asset assetTitle] forKey:@"assetTitle"];
    [data setValue:[asset assetDescription] forKey:@"assetDescription"];
    [data setValue:[asset assetUrl] forKey:@"assetUrl"];
    [data setValue:[asset assetButton] forKey:@"assetButton"];
    [data setValue:[asset assetMetaData] forKey:@"assetMetaData"];
    [data setValue:[asset assetExtra] forKey:@"assetExtra"];
    return data;
}


@end
