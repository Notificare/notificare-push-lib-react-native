//
//  NotificareReactNativeIOSPushHandler.m
//  DoubleConversion
//
//  Created by Joris Verbogt on 11/10/2019.
//

#import "NotificareReactNativeIOSPushHandler.h"
#import "NotificareReactNativeIOSUtils.h"

/**
*
* Helper class to handle NotificarePushLib delegates
*
*/
@implementation NotificareReactNativeIOSPushHandler

- (instancetype)init
{
    self = [super init];
    if (self) {
        _eventQueue = [NSMutableArray new];
        _isLaunched = NO;
    }
    return self;
}

+ (NotificareReactNativeIOSPushHandler *) shared {
    static NotificareReactNativeIOSPushHandler *shared = nil;
    if (shared == nil) {
        static dispatch_once_t oncePredicate;
        dispatch_once(&oncePredicate, ^{
            shared = [[NotificareReactNativeIOSPushHandler alloc] init];
        });
    }
    return shared;
}

-(void) processQueue {
    for (NSDictionary * event in _eventQueue) {
        [[NotificareReactNativeIOS getInstance] dispatchEvent:[event objectForKey:@"event"] body:[event objectForKey:@"notification"]];
    }
    [_eventQueue removeAllObjects];
}

- (void)dispatchEvent:(NSString *)event body:(id)notification {
    if (_isLaunched && [NotificareReactNativeIOS getInstance] != nil) {
        [[NotificareReactNativeIOS getInstance] dispatchEvent:event body:notification];
    } else {
        NSMutableDictionary * queueItem = [NSMutableDictionary new];
        [queueItem setObject:event forKey:@"event"];
        [queueItem setObject:notification forKey:@"notification"];
        [_eventQueue addObject:queueItem];
    }
}

- (void)notificarePushLib:(NotificarePushLib *)library onReady:(nonnull NotificareApplication *)application {
    _isLaunched = YES;
    [self dispatchEvent:@"ready" body:[[NotificareReactNativeIOSUtils shared] dictionaryFromApplication:application]];
    [self processQueue];
}

- (void)notificarePushLib:(NotificarePushLib *)library didRegisterDevice:(nonnull NotificareDevice *)device{
    [self dispatchEvent:@"deviceRegistered" body:[[NotificareReactNativeIOSUtils shared] dictionaryFromDevice:device]];
}

- (void)notificarePushLib:(NotificarePushLib *)library didChangeNotificationSettings:(BOOL)granted{
    NSMutableDictionary * payload = [NSMutableDictionary new];
    [payload setObject:[NSNumber numberWithBool:granted] forKey:@"granted"];
    [self dispatchEvent:@"notificationSettingsChanged" body:payload];
}

- (void)notificarePushLib:(NotificarePushLib *)library didReceiveLaunchURL:(NSURL *)launchURL{
    NSMutableDictionary * payload = [NSMutableDictionary new];
    [payload setObject:[launchURL absoluteString] forKey:@"url"];
    [self dispatchEvent:@"launchUrlReceived" body:payload];
}

- (void)notificarePushLib:(NotificarePushLib *)library didReceiveRemoteNotificationInBackground:(NotificareNotification *)notification withController:(id _Nullable)controller{
    [self dispatchEvent:@"remoteNotificationReceivedInBackground" body:[[NotificareReactNativeIOSUtils shared] dictionaryFromNotification:notification]];
}

- (void)notificarePushLib:(NotificarePushLib *)library didReceiveRemoteNotificationInForeground:(NotificareNotification *)notification withController:(id _Nullable)controller{
    [self dispatchEvent:@"remoteNotificationReceivedInForeground" body:[[NotificareReactNativeIOSUtils shared] dictionaryFromNotification:notification]];
}

- (void)notificarePushLib:(NotificarePushLib *)library didReceiveSystemNotificationInBackground:(NotificareSystemNotification *)notification{
    [self dispatchEvent:@"systemNotificationReceivedInBackground" body:[[NotificareReactNativeIOSUtils shared] dictionaryFromSystemNotification:notification]];
}

- (void)notificarePushLib:(NotificarePushLib *)library didReceiveSystemNotificationInForeground:(NotificareSystemNotification *)notification{
    [self dispatchEvent:@"systemNotificationReceivedInForeground" body:[[NotificareReactNativeIOSUtils shared] dictionaryFromSystemNotification:notification]];
}

- (void)notificarePushLib:(NotificarePushLib *)library didReceiveUnknownNotification:(NSDictionary *)notification{
    [self dispatchEvent:@"unknownNotificationReceived" body:notification];
}

- (void)notificarePushLib:(NotificarePushLib *)library didReceiveUnknownNotificationInBackground:(NSDictionary *)notification {
    [self dispatchEvent:@"unknownNotificationReceivedInBackground" body:notification];
}

- (void)notificarePushLib:(NotificarePushLib *)library didReceiveUnknownNotificationInForeground:(NSDictionary *)notification {
    [self dispatchEvent:@"unknownNotificationReceivedInForeground" body:notification];
}

- (void)notificarePushLib:(NotificarePushLib *)library didReceiveUnknownAction:(NSDictionary *)action forNotification:(NSDictionary *)notification{
    NSMutableDictionary * payload = [NSMutableDictionary new];
    [payload setObject:action forKey:@"action"];
    [payload setObject:notification forKey:@"notification"];
    [self dispatchEvent:@"unknownActionForNotificationReceived" body:payload];
}

- (void)notificarePushLib:(NotificarePushLib *)library willOpenNotification:(NotificareNotification *)notification{
    [self dispatchEvent:@"notificationWillOpen" body:[[NotificareReactNativeIOSUtils shared] dictionaryFromNotification:notification]];
}

- (void)notificarePushLib:(NotificarePushLib *)library didOpenNotification:(NotificareNotification *)notification{
    [self dispatchEvent:@"notificationOpened" body:[[NotificareReactNativeIOSUtils shared] dictionaryFromNotification:notification]];
}

- (void)notificarePushLib:(NotificarePushLib *)library didCloseNotification:(NotificareNotification *)notification{
    [self dispatchEvent:@"notificationClosed" body:[[NotificareReactNativeIOSUtils shared] dictionaryFromNotification:notification]];
}

- (void)notificarePushLib:(NotificarePushLib *)library didFailToOpenNotification:(NotificareNotification *)notification{
    [self dispatchEvent:@"notificationFailedToOpen" body:[[NotificareReactNativeIOSUtils shared] dictionaryFromNotification:notification]];
}

- (void)notificarePushLib:(NotificarePushLib *)library didClickURL:(NSURL *)url inNotification:(NotificareNotification *)notification{
    NSMutableDictionary * payload = [NSMutableDictionary new];
    [payload setObject:[url absoluteString] forKey:@"url"];
    [payload setObject:[[NotificareReactNativeIOSUtils shared] dictionaryFromNotification:notification] forKey:@"notification"];
    [self dispatchEvent:@"urlClickedInNotification" body:payload];
}

- (void)notificarePushLib:(NotificarePushLib *)library willExecuteAction:(NotificareAction *)action{
    [self dispatchEvent:@"actionWillExecute" body:[[NotificareReactNativeIOSUtils shared] dictionaryFromAction:action]];
}

- (void)notificarePushLib:(NotificarePushLib *)library didExecuteAction:(NotificareAction *)action{
    [self dispatchEvent:@"actionExecuted" body:[[NotificareReactNativeIOSUtils shared] dictionaryFromAction:action]];
}

- (void)notificarePushLib:(NotificarePushLib *)library shouldPerformSelectorWithURL:(NSURL *)url inAction:(NotificareAction *)action{
    NSMutableDictionary * payload = [NSMutableDictionary new];
    [payload setObject:[url absoluteString] forKey:@"url"];
    [payload setObject:[[NotificareReactNativeIOSUtils shared] dictionaryFromAction:action] forKey:@"action"];
    [self dispatchEvent:@"shouldPerformSelectorWithUrl" body:payload];
}

- (void)notificarePushLib:(NotificarePushLib *)library didNotExecuteAction:(NotificareAction *)action{
     [self dispatchEvent:@"actionNotExecuted" body:[[NotificareReactNativeIOSUtils shared] dictionaryFromAction:action]];
}

- (void)notificarePushLib:(NotificarePushLib *)library didFailToExecuteAction:(NotificareAction *)action withError:(NSError *)error{
     [self dispatchEvent:@"actionFailedToExecute" body:[[NotificareReactNativeIOSUtils shared] dictionaryFromAction:action]];
}

/*
 * Uncomment this code to implement native PKPasses
 * Additionally you must import PassKit framework in the NotificareReactNativeIOS.h and implement PKAddPassesViewControllerDelegate in the PushHandler interface
 *
- (void)notificarePushLib:(NotificarePushLib *)library didReceivePass:(NSURL *)pass inNotification:(NotificareNotification*)notification{
 
     dispatch_async(dispatch_get_main_queue(), ^{
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
     });
    
}
*/

- (void)notificarePushLib:(NotificarePushLib *)library shouldOpenSettings:(NotificareNotification* _Nullable)notification{
    [self dispatchEvent:@"shouldOpenSettings" body:[[NotificareReactNativeIOSUtils shared] dictionaryFromNotification:notification]];
}


- (void)notificarePushLib:(NotificarePushLib *)library didLoadInbox:(NSArray<NotificareDeviceInbox*>*)items{
    NSMutableArray * inboxItems = [NSMutableArray array];
    for (NotificareDeviceInbox * inboxItem in items) {
        [inboxItems addObject:[[NotificareReactNativeIOSUtils shared] dictionaryFromDeviceInbox:inboxItem]];
    }
    [self dispatchEvent:@"inboxLoaded" body:inboxItems];
}

- (void)notificarePushLib:(NotificarePushLib *)library didUpdateBadge:(int)badge{
    [self dispatchEvent:@"badgeUpdated" body:[NSNumber numberWithInt:badge]];
}


- (void)notificarePushLib:(NotificarePushLib *)library didFailToStartLocationServiceWithError:(NSError *)error{
    NSMutableDictionary * payload = [NSMutableDictionary new];
    [payload setObject:[error localizedDescription] forKey:@"error"];
    [self dispatchEvent:@"locationServiceFailedToStart" body:payload];
}

- (void)notificarePushLib:(NotificarePushLib *)library didReceiveLocationServiceAuthorizationStatus:(NotificareGeoAuthorizationStatus)status{
    
    NSMutableDictionary * payload = [NSMutableDictionary new];
    
    if (status == NotificareGeoAuthorizationStatusDenied) {
        [payload setObject:@"denied" forKey:@"status"];
    } else if (status == NotificareGeoAuthorizationStatusRestricted) {
        [payload setObject:@"restricted" forKey:@"status"];
    } else if (status == NotificareGeoAuthorizationStatusNotDetermined) {
        [payload setObject:@"notDetermined" forKey:@"status"];
    } else if (status == NotificareGeoAuthorizationStatusAuthorizedAlways) {
        [payload setObject:@"always" forKey:@"status"];
    } else if (status == NotificareGeoAuthorizationStatusAuthorizedWhenInUse) {
        [payload setObject:@"whenInUse" forKey:@"status"];
    }
    
    [self dispatchEvent:@"locationServiceAuthorizationStatusReceived" body:payload];
    
}

- (void)notificarePushLib:(NotificarePushLib *)library didReceiveLocationServiceAccuracyAuthorization:(NotificareGeoAccuracyAuthorization)accuracy {
    NSMutableDictionary * payload = [NSMutableDictionary new];
    
    if (accuracy == NotificareGeoAccuracyAuthorizationFull) {
        [payload setObject:@"full" forKey:@"accuracy"];
    } else if (accuracy == NotificareGeoGeoAccuracyAuthorizationReduced) {
        [payload setObject:@"reduced" forKey:@"accuracy"];
    }

    [self dispatchEvent:@"locationServiceAccuracyAuthorizationReceived" body:payload];
}

- (void)notificarePushLib:(NotificarePushLib *)library didUpdateLocations:(NSArray<NotificareLocation*> *)locations{
    NSMutableArray * payload = [NSMutableArray new];
    for (NotificareLocation * location in locations) {
        [payload addObject:[[NotificareReactNativeIOSUtils shared] dictionaryFromLocation:location]];
    }
    [self dispatchEvent:@"locationsUpdated" body:payload];
}

- (void)notificarePushLib:(NotificarePushLib *)library monitoringDidFailForRegion:(id)region withError:(NSError *)error{
    NSMutableDictionary * payload = [NSMutableDictionary new];
    [payload setObject:[error localizedDescription] forKey:@"error"];
    [self dispatchEvent:@"monitoringForRegionFailed" body:payload];
}

- (void)notificarePushLib:(NotificarePushLib *)library didStartMonitoringForRegion:(id)region{
    
    if([region isKindOfClass:[NotificareRegion class]]){
        [self dispatchEvent:@"monitoringForRegionStarted" body:[[NotificareReactNativeIOSUtils shared] dictionaryFromRegion:region]];
    }
    
    if([region isKindOfClass:[NotificareBeacon class]]){
        [self dispatchEvent:@"monitoringForRegionStarted" body:[[NotificareReactNativeIOSUtils shared] dictionaryFromBeacon:region]];
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
        [payload setObject:[[NotificareReactNativeIOSUtils shared] dictionaryFromBeacon:region] forKey:@"region"];
    }
    
    [self dispatchEvent:@"stateForRegionChanged" body:payload];
}

- (void)notificarePushLib:(NotificarePushLib *)library didEnterRegion:(id)region{
    
    if([region isKindOfClass:[NotificareRegion class]]){
        [self dispatchEvent:@"regionEntered" body:[[NotificareReactNativeIOSUtils shared] dictionaryFromRegion:region]];
    }
    
    if([region isKindOfClass:[NotificareBeacon class]]){
        [self dispatchEvent:@"regionEntered" body:[[NotificareReactNativeIOSUtils shared] dictionaryFromBeacon:region]];
    }
}

- (void)notificarePushLib:(NotificarePushLib *)library didExitRegion:(id)region{
    
    if([region isKindOfClass:[NotificareRegion class]]){
        [self dispatchEvent:@"regionExited" body:[[NotificareReactNativeIOSUtils shared] dictionaryFromRegion:region]];
    }
    
    if([region isKindOfClass:[NotificareBeacon class]]){
        [self dispatchEvent:@"regionExited" body:[[NotificareReactNativeIOSUtils shared] dictionaryFromBeacon:region]];
    }
    
}

- (void)notificarePushLib:(NotificarePushLib *)library rangingBeaconsDidFailForRegion:(NotificareBeacon *)region withError:(NSError *)error{
    NSMutableDictionary * payload = [NSMutableDictionary new];
    [payload setObject:[error localizedDescription] forKey:@"error"];
    [payload setObject:[[NotificareReactNativeIOSUtils shared] dictionaryFromBeacon:region] forKey:@"region"];
    [self dispatchEvent:@"rangingBeaconsFailed" body:payload];
}

- (void)notificarePushLib:(NotificarePushLib *)library didRangeBeacons:(NSArray<NotificareBeacon *> *)beacons inRegion:(NotificareBeacon *)region{
    NSMutableDictionary * payload = [NSMutableDictionary new];
    NSMutableArray * beaconsList = [NSMutableArray new];
    for (NotificareBeacon * beacon in beacons) {
        [beaconsList addObject:[[NotificareReactNativeIOSUtils shared] dictionaryFromBeacon:beacon]];
    }
    [payload setObject:beaconsList forKey:@"beacons"];
    [payload setObject:[[NotificareReactNativeIOSUtils shared] dictionaryFromBeacon:region] forKey:@"region"];
    [self dispatchEvent:@"beaconsInRangeForRegion" body:payload];
}

- (void)notificarePushLib:(NotificarePushLib *)library didUpdateHeading:(NotificareHeading*)heading{
    [self dispatchEvent:@"headingUpdated" body:[[NotificareReactNativeIOSUtils shared] dictionaryFromHeading:heading]];
}

- (void)notificarePushLib:(NotificarePushLib *)library didVisit:(NotificareVisit*)visit{
    [self dispatchEvent:@"visitReceived" body:[[NotificareReactNativeIOSUtils shared] dictionaryFromVisit:visit]];
}

- (void)notificarePushLib:(NotificarePushLib *)library didReceiveActivationToken:(NSString *)token{
    NSMutableDictionary * payload = [NSMutableDictionary new];
    [payload setObject:token forKey:@"token"];
    [self dispatchEvent:@"activationTokenReceived" body:payload];
}

- (void)notificarePushLib:(NotificarePushLib *)library didReceiveResetPasswordToken:(NSString *)token{
    NSMutableDictionary * payload = [NSMutableDictionary new];
    [payload setObject:token forKey:@"token"];
    [self dispatchEvent:@"resetPasswordTokenReceived" body:payload];
}

- (void)notificarePushLib:(NotificarePushLib *)library didLoadStore:(NSArray<NotificareProduct *> *)products{
    NSMutableArray * payload = [NSMutableArray array];
    for (NotificareProduct * product in products) {
        [payload addObject:[[NotificareReactNativeIOSUtils shared] dictionaryFromProduct:product]];
    }
    [self dispatchEvent:@"storeLoaded" body:payload];
}

- (void)notificarePushLib:(NotificarePushLib *)library didFailToLoadStore:(NSError *)error{
    NSMutableDictionary * payload = [NSMutableDictionary new];
    [payload setObject:[error localizedDescription] forKey:@"error"];
    [self dispatchEvent:@"storeFailedToLoad" body:payload];
}

- (void)notificarePushLib:(NotificarePushLib *)library didCompleteProductTransaction:(SKPaymentTransaction *)transaction{
    [[NotificarePushLib shared] fetchProduct:[[transaction payment] productIdentifier] completionHandler:^(id  _Nullable response, NSError * _Nullable error) {
        [self dispatchEvent:@"productTransactionCompleted" body:[[NotificareReactNativeIOSUtils shared] dictionaryFromProduct:response]];
    }];
}

- (void)notificarePushLib:(NotificarePushLib *)library didRestoreProductTransaction:(SKPaymentTransaction *)transaction{
    [[NotificarePushLib shared] fetchProduct:[[transaction payment] productIdentifier] completionHandler:^(id  _Nullable response, NSError * _Nullable error) {
        [self dispatchEvent:@"productTransactionRestored" body:[[NotificareReactNativeIOSUtils shared] dictionaryFromProduct:response]];
    }];
}

- (void)notificarePushLib:(NotificarePushLib *)library didFailProductTransaction:(SKPaymentTransaction *)transaction withError:(NSError *)error{
    [[NotificarePushLib shared] fetchProduct:[[transaction payment] productIdentifier] completionHandler:^(id  _Nullable response, NSError * _Nullable error) {
        NSMutableDictionary * payload = [NSMutableDictionary new];
        [payload setObject:[error localizedDescription] forKey:@"error"];
        [payload setObject:[[NotificareReactNativeIOSUtils shared] dictionaryFromProduct:response] forKey:@"product"];
        [self dispatchEvent:@"productTransactionFailed" body:payload];
    }];
}

- (void)notificarePushLib:(NotificarePushLib *)library didStartDownloadContent:(SKPaymentTransaction *)transaction{
    [[NotificarePushLib shared] fetchProduct:[[transaction payment] productIdentifier] completionHandler:^(id  _Nullable response, NSError * _Nullable error) {
        [self dispatchEvent:@"productContentDownloadStarted" body:[[NotificareReactNativeIOSUtils shared] dictionaryFromProduct:response]];
    }];
}

- (void)notificarePushLib:(NotificarePushLib *)library didPauseDownloadContent:(SKDownload *)download{
    [[NotificarePushLib shared] fetchProduct:[[[download transaction] payment] productIdentifier] completionHandler:^(id  _Nullable response, NSError * _Nullable error) {
        NSMutableDictionary * payload = [NSMutableDictionary new];
        [payload setObject:[[NotificareReactNativeIOSUtils shared] dictionaryFromSKDownload:download] forKey:@"download"];
        [payload setObject:[[NotificareReactNativeIOSUtils shared] dictionaryFromProduct:response] forKey:@"product"];
        [self dispatchEvent:@"productContentDownloadPaused" body:payload];
    }];
}

- (void)notificarePushLib:(NotificarePushLib *)library didCancelDownloadContent:(SKDownload *)download{
    [[NotificarePushLib shared] fetchProduct:[[[download transaction] payment] productIdentifier] completionHandler:^(id  _Nullable response, NSError * _Nullable error) {
        NSMutableDictionary * payload = [NSMutableDictionary new];
        [payload setObject:[[NotificareReactNativeIOSUtils shared] dictionaryFromSKDownload:download] forKey:@"download"];
        [payload setObject:[[NotificareReactNativeIOSUtils shared] dictionaryFromProduct:response] forKey:@"product"];
        [self dispatchEvent:@"productContentDownloadCancelled" body:payload];
    }];
}

- (void)notificarePushLib:(NotificarePushLib *)library didReceiveProgressDownloadContent:(SKDownload *)download{
    [[NotificarePushLib shared] fetchProduct:[[[download transaction] payment] productIdentifier] completionHandler:^(id  _Nullable response, NSError * _Nullable error) {
        NSMutableDictionary * payload = [NSMutableDictionary new];
        [payload setObject:[[NotificareReactNativeIOSUtils shared] dictionaryFromSKDownload:download] forKey:@"download"];
        [payload setObject:[[NotificareReactNativeIOSUtils shared] dictionaryFromProduct:response] forKey:@"product"];
        [self dispatchEvent:@"productContentDownloadProgress" body:payload];
    }];
}

- (void)notificarePushLib:(NotificarePushLib *)library didFailDownloadContent:(SKDownload *)download{
    [[NotificarePushLib shared] fetchProduct:[[[download transaction] payment] productIdentifier] completionHandler:^(id  _Nullable response, NSError * _Nullable error) {
        NSMutableDictionary * payload = [NSMutableDictionary new];
        [payload setObject:[[NotificareReactNativeIOSUtils shared] dictionaryFromSKDownload:download] forKey:@"download"];
        [payload setObject:[[NotificareReactNativeIOSUtils shared] dictionaryFromProduct:response] forKey:@"product"];
        [self dispatchEvent:@"productContentDownloadFailed" body:payload];
    }];
}

- (void)notificarePushLib:(NotificarePushLib *)library didFinishDownloadContent:(SKDownload *)download{
    [[NotificarePushLib shared] fetchProduct:[[[download transaction] payment] productIdentifier] completionHandler:^(id  _Nullable response, NSError * _Nullable error) {
        NSMutableDictionary * payload = [NSMutableDictionary new];
        [payload setObject:[[NotificareReactNativeIOSUtils shared] dictionaryFromSKDownload:download]forKey:@"download"];
        [payload setObject:[[NotificareReactNativeIOSUtils shared] dictionaryFromProduct:response] forKey:@"product"];
        [self dispatchEvent:@"productContentDownloadFinished" body:payload];
    }];
}


- (void)notificarePushLib:(NotificarePushLib *)library didStartQRCodeScanner:(UIViewController*)scanner{
    [self dispatchEvent:@"qrCodeScannerStarted" body:[NSNull null]];
}

- (void)notificarePushLib:(NotificarePushLib *)library didInvalidateScannableSessionWithError:(NSError *)error{
    NSMutableDictionary * payload = [NSMutableDictionary new];
    [payload setObject:[error localizedDescription] forKey:@"error"];
    [self dispatchEvent:@"scannableSessionInvalidatedWithError" body:payload];
}

- (void)notificarePushLib:(NotificarePushLib *)library didDetectScannable:(NotificareScannable *)scannable{
    [self dispatchEvent:@"scannableDetected" body:[[NotificareReactNativeIOSUtils shared] dictionaryFromScannable:scannable]];
}

@end
