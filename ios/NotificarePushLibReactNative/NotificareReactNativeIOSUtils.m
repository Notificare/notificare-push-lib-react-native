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
    if ([dictionary objectForKey:@"content"] && [[dictionary objectForKey:@"content"] count] > 0) {
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
    if ([dictionary objectForKey:@"actions"] && [[dictionary objectForKey:@"actions"] count] > 0) {
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
    if ([dictionary objectForKey:@"attachments"] && [[dictionary objectForKey:@"attachments"] count] > 0) {
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

-(NSDictionary *)dictionaryFromSystemNotification:(NotificareSystemNotification *)notification{
    NSMutableDictionary * data = [NSMutableDictionary dictionary];
    [data setValue:[notification notificationID] forKey:@"notificationID"];
    [data setValue:[notification type] forKey:@"type"];
    [data setValue:[notification extra] forKey:@"extra"];
    return data;
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

-(NSDictionary *)dictionaryFromPass:(NotificarePass *)pass{
    NSMutableDictionary * data = [NSMutableDictionary dictionary];
    [data setValue:[pass passbook] forKey:@"passbook"];
    [data setValue:[pass barcode] forKey:@"barcode"];
    [data setValue:[pass serial] forKey:@"serial"];
    [data setValue:[pass redeem] forKey:@"redeem"];
    [data setValue:[pass token] forKey:@"token"];
    [data setValue:[pass passURL] forKey:@"passURL"];
    [data setValue:[pass date] forKey:@"date"];
    [data setValue:[pass data] forKey:@"data"];
    [data setValue:[pass limit] forKey:@"limit"];
    [data setValue:[pass redeemHistory] forKey:@"redeemHistory"];
    [data setObject:[NSNumber numberWithBool:[pass active]] forKey:@"active"];
    return data;
}

-(NSDictionary *)dictionaryFromProduct:(NotificareProduct *)product{
    NSMutableDictionary * data = [NSMutableDictionary dictionary];
    [data setValue:[product productName] forKey:@"productName"];
    [data setValue:[product productDescription] forKey:@"productDescription"];
    [data setValue:[product productType] forKey:@"productType"];
    [data setValue:[product application] forKey:@"application"];
    [data setValue:[product productIdentifier] forKey:@"productIdentifier"];
    [data setValue:[product productStores] forKey:@"productStores"];
    //[data setValue:[product productDownloads] forKey:@"productDownloads"];
    [data setValue:[product productDate] forKey:@"productDate"];
    [data setValue:[product productPriceLocale] forKey:@"productPriceLocale"];
    [data setValue:[product productPrice] forKey:@"productPrice"];
    [data setValue:[product productCurrency] forKey:@"productCurrency"];
    [data setObject:[NSNumber numberWithBool:[product active]] forKey:@"active"];
    [data setObject:[NSNumber numberWithBool:[product purchased]] forKey:@"purchased"];
    return data;
}

-(NSDictionary *)dictionaryFromUser:(NotificareUser *)user{
    NSMutableDictionary * data = [NSMutableDictionary dictionary];
    [data setValue:[user accessToken] forKey:@"accessToken"];
    [data setValue:[user account] forKey:@"account"];
    [data setValue:[user application] forKey:@"application"];
    [data setValue:[user segments] forKey:@"segments"];
    [data setValue:[user userID] forKey:@"userID"];
    [data setValue:[user userName] forKey:@"userName"];
    [data setValue:[user userData] forKey:@"userData"];
    [data setObject:[NSNumber numberWithBool:[user validated]] forKey:@"validated"];
    [data setObject:[NSNumber numberWithBool:[user autoGenerated]] forKey:@"autoGenerated"];
    [data setObject:[NSNumber numberWithBool:[user active]] forKey:@"active"];
    return data;
}

-(NSDictionary *)dictionaryFromUserPreference:(NotificareUserPreference *)preference{
    NSMutableDictionary * data = [NSMutableDictionary dictionary];
    [data setValue:[preference preferenceLabel] forKey:@"preferenceLabel"];
    [data setValue:[preference preferenceId] forKey:@"preferenceId"];
    [data setValue:[preference preferenceType] forKey:@"preferenceType"];
    
    NSMutableArray * segments = [NSMutableArray new];
    if ([preference preferenceOptions] && [[preference preferenceOptions] count] > 0){
        for (NotificareSegment *segment in [preference preferenceOptions]) {
            NSMutableDictionary * s = [NSMutableDictionary dictionary];
            [s setValue:[segment segmentLabel] forKey:@"segmentLabel"];
            [s setValue:[segment segmentId] forKey:@"segmentId"];
            [s setObject:[NSNumber numberWithBool:[segment selected]] forKey:@"selected"];
            [segments addObject:s];
        }
    }

    [data setValue:segments forKey:@"preferenceOptions"];
    return data;
}

-(NotificareUserPreference *)userPreferenceFromDictionary:(NSDictionary *)dictionary{
    NotificareUserPreference * preference = [NotificareUserPreference new];
    [preference setPreferenceLabel:[dictionary objectForKey:@"preferenceLabel"]];
    [preference setPreferenceId:[dictionary objectForKey:@"preferenceId"]];
    [preference setPreferenceType:[dictionary objectForKey:@"preferenceType"]];
    
    NSMutableArray * segments = [NSMutableArray new];
    if ([dictionary objectForKey:@"preferenceOptions"] && [[dictionary objectForKey:@"preferenceOptions"] count] > 0) {
        for (NSDictionary *s in [dictionary objectForKey:@"preferenceOptions"]) {
            NotificareSegment * segment = [NotificareSegment new];
            [segment setSegmentLabel:[s objectForKey:@"segmentLabel"]];
            [segment setSegmentId:[s objectForKey:@"segmentId"]];
            [segment setSelected:[[s objectForKey:@"selected"] boolValue]];
        }
    }
    [preference setPreferenceOptions:segments];
    
    return preference;
}

-(NSDictionary *)dictionaryFromSegment:(NotificareSegment *)segment{
    NSMutableDictionary * data = [NSMutableDictionary dictionary];
    [data setValue:[segment segmentLabel] forKey:@"segmentLabel"];
    [data setValue:[segment segmentId] forKey:@"segmentId"];
    [data setObject:[NSNumber numberWithBool:[segment selected]] forKey:@"selected"];
    return data;
}

-(NotificareSegment *)segmentFromDictionary:(NSDictionary *)dictionary{
    NotificareSegment * segment = [NotificareSegment new];
    [segment setSegmentLabel:[dictionary objectForKey:@"segmentLabel"]];
    [segment setSegmentId:[dictionary objectForKey:@"segmentId"]];
    [segment setSelected:[[dictionary objectForKey:@"selected"] boolValue]];
    return segment;
}

-(NSDictionary *)dictionaryFromLocation:(NotificareLocation *)location{
    NSMutableDictionary * data = [NSMutableDictionary dictionary];
    [data setValue:[location latitude] forKey:@"latitude"];
    [data setValue:[location longitude] forKey:@"longitude"];
    [data setValue:[location altitude] forKey:@"altitude"];
    [data setValue:[location horizontalAccuracy] forKey:@"horizontalAccuracy"];
    [data setValue:[location verticalAccuracy] forKey:@"verticalAccuracy"];
    [data setValue:[location floor] forKey:@"floor"];
    [data setValue:[location speed] forKey:@"speed"];
    [data setValue:[location course] forKey:@"course"];
    [data setValue:[location timestamp] forKey:@"timestamp"];
    return data;
}

-(NSDictionary *)dictionaryFromBeacon:(NotificareBeacon *)beacon{
    NSMutableDictionary * data = [NSMutableDictionary dictionary];
    [data setValue:[beacon application] forKey:@"application"];
    [data setValue:[beacon beaconId] forKey:@"beaconId"];
    [data setValue:[beacon beaconName] forKey:@"beaconName"];
    [data setValue:[beacon beaconRegion] forKey:@"beaconRegion"];
    [data setValue:[[beacon beaconUUID] UUIDString] forKey:@"beaconUUID"];
    [data setValue:[beacon beaconRegion] forKey:@"beaconMajor"];
    [data setValue:[beacon beaconRegion] forKey:@"beaconMinor"];
    //[data setValue:[beacon beacon] forKey:@"beacon"];
    [data setObject:[NSNumber numberWithBool:[beacon beaconTriggers]] forKey:@"beaconTriggers"];
    return data;
}

-(NSDictionary *)dictionaryFromRegion:(NotificareRegion *)region{
    NSMutableDictionary * data = [NSMutableDictionary dictionary];
    [data setValue:[region application] forKey:@"application"];
    [data setValue:[region regionId] forKey:@"regionId"];
    [data setValue:[region regionName] forKey:@"regionName"];
    [data setValue:[region regionDescription] forKey:@"regionDescription"];
    [data setValue:[region regionReferenceKey] forKey:@"regionReferenceKey"];
    [data setValue:[region regionMajor] forKey:@"regionMajor"];
    [data setValue:[region regionAddress] forKey:@"regionAddress"];
    [data setValue:[region regionCountry] forKey:@"regionCountry"];
    [data setValue:[region regionTags] forKey:@"regionTags"];
    [data setValue:[region regionGeometry] forKey:@"regionGeometry"];
    [data setValue:[region regionAdvancedGeometry] forKey:@"regionAdvancedGeometry"];
    [data setValue:[region regionDistance] forKey:@"regionDistance"];
    [data setValue:[region regionTimezone] forKey:@"regionTimezone"];
    [data setValue:[region regionTimeZoneOffset] forKey:@"regionTimeZoneOffset"];
    [data setValue:[region regionWeather] forKey:@"regionWeather"];
    return data;
}

@end
