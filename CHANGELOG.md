## 2.7.0-beta.1
- Update native Android dependency to 2.7.0-beta.4
- Update native iOS dependency to 2.7-beta2
- Update plugin gradle file
- Add handled flags for openUrl and continueUserActivity

##### BREAKING CHANGE: ANDROID NOTIFICATION TRAMPOLINE
Add the following to your `Manifest.xml`:

```xml
<activity android:name=".MainActivity">

    <!-- existing intent filters  -->

    <intent-filter>
        <action android:name="re.notifica.intent.action.RemoteMessageOpened" />
        <category android:name="android.intent.category.DEFAULT" />
    </intent-filter>

</activity>
```

For more information about this subject please take a look at [this](https://github.com/Notificare/notificare-push-lib-android-src/blob/2.7-dev/UPGRADE.md#breaking-change-trampoline-intents) section.

##### BREAKING CHANGE: ANDROID BLUETOOTH PERMISSION
From Android 12 and up, bluetooth scanning permissions have to be requested at runtime. This impacts the geofencing functionality of our library. 

## 2.6.1
- Prevent the native Android module from breaking the React Native Linking module

## 2.6.0
- Update native Android dependency
- Update native iOS dependency
- Handle test device registration

## 2.5.5
- Update native iOS dependency
- Improve present notifications, inbox items & scannables transition & styling

## 2.5.4
- Update native Android dependency

## 2.5.3
- Prevent crash on mapping inbox items without a notification
- Update native iOS dependency

## 2.5.2
- Prevent crash on inbox updates after un-launching

## 2.5.1
- Add `extra` to assets
- Allow nullable asset URLs

## 2.5.0
- Update native Android SDK to 2.5.0
- Update native iOS SDK to 2.5.0
- Add beacon scanning foreground service

## 2.4.1
- Update dependencies
- Fix logkitty & lodash vulnerabilities

## 2.4.0-beta.2
- Add `targetContentIdentifier` to `NotificareNotification`
- Update native iOS SDK to v2.4.0-beta.7

## 2.4.0-beta.1
- update native SDKs to v2.4.0-beta
- refactor Billing Manager integration
- add `unknownNotificationReceivedInBackground` and `unknownNotificationReceivedInForeground` events on iOS
- add `markAllAsRead` method
- add `accuracy` to `NotificareDevice`
- add support for Dynamic Links
- add 'ephemeral' authorization status
- add `requestAlwaysAuthorizationForLocationUpdates` and `requestTemporaryFullAccuracyAuthorization` methods

2.3.2 03-09-2020
- Fix `updateUserData` method consistency between platforms

2.3.1 28-08-2020
- Add `urlOpened` event to Android

2.3.0 25-06-2020
- Fix `doCloudHostOperation` invocations
- Add `accessToken` to `NotificareUser`
- Fix user preferences parsing
- Fix ranging beacons payload
- Update Android SDK to v2.3.0
- Update iOS SDK to v2.3.2
- Allow `carPlay` in authorization options

2.2.6 29-04-2020
- Updated to Android SDK 2.2.3

2.2.5 15-04-2020
- Updated to Android SDK 2.2.2

2.2.4 27-02-2020
- Check partially fetched notifications when fetching inbox items 

2.2.3 19-02-2020
- Updated to iOS SDK 2.2.6
- Updated to React Native 0.61.5

2.2.2 20-11-2019
- Updated to iOS SDK 2.2.4
- Changes to isViewController method

2.2.1 12-11-2019
- Updated to Android SDK 2.2.1
- Updated to iOS SDK 2.2.3

2.2.0 30-10-2019
- Updated to Android SDK 2.2.0

2.1.3 29-10-2019
- Guard against passing NaN values in Android device location

2.1.2 28-10-2019
- Added no-op for Android-only methods in iOS
- Updated podspec to use iOS lib 2.2.2
- Updated Android 2.1.2

2.1.1 14-10-2019
- Added event queue to iOS

2.1.0 01-10-2019
- Updated to use ReactNative 0.60+
- Updated to Android SDK 2.1.0
- Updated to iOS SDK 2.2.0

2.0.12 01-10-2019
- Added missing properties to Android inbox item

2.0.10 23-09-2019
- Start inbox observing on main thread

2.0.9 23-09-2019
- Fixed registerDevice in Android
- Fixed updateUserData in Android

2.0.8 18-09-2019
- Fixed crash in delegate didDetermineState when a beacon region was found

2.0.7 13-09-2019
- Updated to latest iOS library and necessary changes in handling launch options

2.0.6 09-09-2019
- Updated to latest iOS library

2.0.5 05-08-2019
- Updated to latest iOS and Android native libs

2.0.4 18-07-2019
- Updated to iOS 2.1.2
- Fixed crash when launch options contains a UIApplicationLaunchOptionsURLKey

2.0.3 15-07-2019
- Updated to Notificare Android SDK 2.0.7
- Made sure all UI presentation methods run in main thread

2.0.2 11-07-2019
- Added aliases for isRemoteNotificationsEnabled and isAllowedUIEnabled and isLocationServicesEnabled
- Updated iOS lib to latest version 

2.0.1 05-07-2019
- Removed location permissions by default

2.0.0 21-06-2019
- Release 2.0.0
