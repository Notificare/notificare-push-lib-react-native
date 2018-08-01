# Notificare Push Lib for React Native

## Quick Setup

To start please make sure you have followed the [Getting started with React Native tutorial](https://facebook.github.io/react-native/docs/getting-started.html). 
Once you have met all the requirements and you have prepared your machine for React Native development you can then start implementing our module.

### Install the module 

```sh
react-native install notificare-push-lib-react-native
```

### Android
The above step should do this for you, but it's good to check if it did change the android/settings.gradle file:

```gradle
include ':notificare-push-lib-react-native'
project(':notificare-push-lib-react-native').projectDir = file('../node_modules/notificare-push-lib-react-native/android')
```

Add the following as a dependency in the android/app/build.gradle file

```gradle
dependencies {
    ...
    implementation project(':notificare-push-lib-react-native')
    ...
}
```
Follow the rest of the implementation on the [Notificare Documentation](https://docs.notifica.re/sdk/implementation/)

### iOS
The install step should do this for you, but if you want to make sure our native library is linked to your project, use:

```sh
react-native link
```



Follow the rest of the implementation on the [Notificare Documentation](https://docs.notifica.re/sdk/implementation/)


