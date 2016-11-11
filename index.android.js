/**
 * Sample React Native App
 * https://github.com/facebook/react-native
 * @flow
 */

import React, { Component } from 'react';
import {
  AppRegistry,
  StyleSheet,
  NativeModules,
  DeviceEventEmitter,
  Text,
  View
} from 'react-native';

const Notificare = NativeModules.NotificareReactNativeAndroid;

export default class AwesomeProject extends Component {

  componentWillMount() {

    Notificare.launch();

    DeviceEventEmitter.addListener('onReady', function(e: Event) {
        console.log(e);
        Notificare.enableNotifications();
    });

    DeviceEventEmitter.addListener('didReceiveDeviceToken', function(e: Event) {
        console.log(e);

      	Notificare.registerDevice(e.device, null, null, (error, msg) => {
          if (!error) {
            Notificare.fetchTags((error, msg) => {
              console.log(msg);
            });
          }
    	  });

    });


    DeviceEventEmitter.addListener('onNotificationReceived', function(e: Event) {
      console.log(e);
    });

    DeviceEventEmitter.addListener('onNotificationOpened', function(e: Event) {
      Notificare.openNotification(e);
    });
  }

  render() {
    return (
      <View style={styles.container}>
        <Text style={styles.welcome}>
          Welcome to React Native!
        </Text>
        <Text style={styles.instructions}>
          To get started, edit index.android.js
        </Text>
        <Text style={styles.instructions}>
          Double tap R on your keyboard to reload,{'\n'}
          Shake or press menu button for dev menu
        </Text>
      </View>
    );
  }
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    justifyContent: 'center',
    alignItems: 'center',
    backgroundColor: '#F5FCFF',
  },
  welcome: {
    fontSize: 20,
    textAlign: 'center',
    margin: 10,
  },
  instructions: {
    textAlign: 'center',
    color: '#333333',
    marginBottom: 5,
  },
});

AppRegistry.registerComponent('AwesomeProject', () => AwesomeProject);
