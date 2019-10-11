//
//  NotificareReactNativeIOSPushHandler.h
//  DoubleConversion
//
//  Created by Joris Verbogt on 11/10/2019.
//

#import <Foundation/Foundation.h>
#import "NotificarePushLib.h"
//#import <PassKit/PassKit.h>
#import "NotificareReactNativeIOS.h"

NS_ASSUME_NONNULL_BEGIN

@interface NotificareReactNativeIOSPushHandler : NSObject <NotificarePushLibDelegate/*,PKAddPassesViewControllerDelegate*/>
@property(nonatomic, strong) NSMutableArray * _Nullable eventQueue;
@property(nonatomic, assign) BOOL isLaunched;
+(NotificareReactNativeIOSPushHandler *_Nonnull)shared;
-(void)processQueue;
-(void)dispatchEvent:(NSString *_Nonnull) event body:(id _Nonnull ) body;
@end

NS_ASSUME_NONNULL_END
