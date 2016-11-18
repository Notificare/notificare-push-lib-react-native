/**
 * Sample React Native App
 * https://github.com/facebook/react-native
 * @flow
 */

import React, { Component } from 'react';
import {
  AppRegistry,
  ListView,
  StyleSheet,
  Text,
  NativeModules,
  DeviceEventEmitter,
  TouchableHighlight,
  View,
  PermissionsAndroid
} from 'react-native';

const Notificare = NativeModules.NotificareReactNativeAndroid;

export default class AwesomeProject extends Component {
  
  constructor(props) {
    super(props);
    const ds = new ListView.DataSource({rowHasChanged: (r1, r2) => r1 !== r2});
    this.state = {
      dataSource: ds.cloneWithRows([])
    };
    this._reloadInbox();
  }

  componentDidMount() {
    console.log('componentDidMount');
    this.setState({mounts: this.state.mounts + 1});

    Notificare.mount();

    DeviceEventEmitter.addListener('ready', function(e: Event) {
        console.log(e);
        Notificare.enableNotifications();
    });

    DeviceEventEmitter.addListener('didReceiveDeviceToken', function(e: Event) {
        console.log(e);

        Notificare.registerDevice(e.device, null, null, (error, msg) => {
          if (!error) {
            Notificare.fetchTags((error, data) => {
              if (!error) {
                console.log(data);
                Notificare.addTags(["react-native"], (error, data) => {
                  if (!error) {
                    console.log(data);
                  }
                });
              }
            });
            (async function() {
              try {
                let granted = await PermissionsAndroid.requestPermission(PermissionsAndroid.PERMISSIONS.ACCESS_FINE_LOCATION, {
                  'title': 'Location Permission',
                  'message': 'We need your location so we can send you relevant push notifications'
                });
                if (granted) {
                  Notificare.enableLocationUpdates()
                }
              } catch (err) {
                console.warn(err)
              }
            }());
          }
        });

    });


    DeviceEventEmitter.addListener('notificationReceived', (e: Event) => {
      console.log(e);
      this._reloadInbox();
    });

    DeviceEventEmitter.addListener('notificationOpened', (e: Event) => {
      console.log(e);
      Notificare.openNotification(e.notification);
    });
  }

  componentWillUnmount() {
    console.log('componentWillUnmount');
    Notificare.unmount();
    DeviceEventEmitter.removeAllListeners();
  }

  _reloadInbox (){
    Notificare.fetchInbox(null, 0, 100, (error, data) => {
            if (!error) {
              console.log(data);
              this.setState({
                dataSource : this.state.dataSource.cloneWithRows(data.inbox)
              });
            }
        });
  }

  render() {
    return (
        <View style={styles.view}>
        <ListView
          enableEmptySections={true}
          dataSource={this.state.dataSource}
          renderRow={this.renderRow}
          />
        </View>
    );
  }

  renderRow (rowData) {
        return (
          <TouchableHighlight>
          <View>
            <View style={styles.row}>
                <Text style={styles.text}>
                {rowData.message}
                </Text>
                <Text style={styles.text}>
                  {rowData.time}
                </Text>
            </View>
          </View>
          </TouchableHighlight>
      );
  }
}

const styles = StyleSheet.create({
  view: {flex: 1, paddingTop: 22},
  row: {
    flexDirection: 'row',
    justifyContent: 'center',
    paddingTop: 20,
    paddingBottom: 20,
    paddingLeft: 10,
    paddingRight: 5,
    backgroundColor: '#F6F6F6',
  },
  text: {
    flex: 1,
    fontSize: 12,
  }
});

AppRegistry.registerComponent('AwesomeProject', () => AwesomeProject);

