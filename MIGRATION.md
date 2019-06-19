# Migration

If you are migrating from 1.x.x version of our plugin, there are several breaking changes that you will need to take into consideration. Some crucial steps required in version 1 were removed and replaced with a simplified new API that unifies integration of remote notifications, location services, user authentication, contextual content and analytics for iOS 9 and up and Android 4.4 and up.

Guides for setup and implementation can be found here:

### iOS:
https://docs.notifica.re/sdk/v2/react-native/ios/setup/

### Android:
https://docs.notifica.re/sdk/v2/react-native/android/setup/


## Initialization
A few changes were introduces when initializing the library, mainly a new method is required to initialize the library (where you can override Notificare.plist app keys). This creates a clear separation between the moment you initialize our plugin and when you actually want to start using it.

You can find more information about initialization here:

### iOS:
https://docs.notifica.re/sdk/v2/react-native/ios/implementation/

### Android:
https://docs.notifica.re/sdk/v2/react-native/android/implementation/

## Device Registration

When you are migrating from older versions, you will notice that you no longer need to take action whenever a device token is registered, as device registration in SDK 2.0 is totally managed by Notificare. You can still register/unregister a device to/from a userID and userName and Notificare will always keep that information cached in the device. This will make sure that whenever a device token changes everything is correctly handled without the need for your app to handle it. 

It is also important to mention that the first time an app is launched we will assign a UUID token to the device before you even request to register for notifications. Basically with this new SDK all features of Notificare can still be used even if your app does not implement remote notifications. Obviously if you never request to register for notifications, users will never receive remote notifications, although messages will still be in the inbox (if implemented), tags can be registered, location services can be used and pretty much all features will work as expected.

Once you decide to register for notifications, those automatically assigned device tokens will be replaced by the APNS tokens assign to each device. 

Bottom line, for this version you should remove all the device registration delegates used in previous versions and optionally you can implement the new delegates which are merely informative. You can find more information about device registration here:

### iOS:
https://docs.notifica.re/sdk/v2/react-native/ios/implementation/register/ 

### Android:
https://docs.notifica.re/sdk/v2/react-native/android/implementation/register/

## Promises
In this new version we've added support for javascript Promises in all methods that used callback functions. This means that some refactoring is required to make your current implementation work with this plugin. For example a method that would look like this:

```
Notificare.addTag("tag_example", (data, error) => {
  if (!error) {
    //Success
  } else {
    //Error
  }
});
```

Should now become:
```
Notificare.addTag("tag_example").then((data) => {
  //Success
}).catch((e) => {
  //Error
});
```

## Events
This new version also introduces breaking changes to almost all the events triggered by our plugin. Please review below all the events supported by our new version:

| Event                          |    iOS    |  Android  |
|--------------------------------|:---------:|----------:|
| ready                          |    [x]    |    [x]    |
