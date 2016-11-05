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
  NativeEventEmitter,
  TouchableHighlight,
  View
} from 'react-native';


const Notificare = NativeModules.NotificareReactNativeIOS;

export default class AwesomeProject extends Component {

  constructor(props){
    super(props);
    this.eventEmitter = new NativeEventEmitter(Notificare);
    const ds = new ListView.DataSource({rowHasChanged: (r1, r2) => r1 !== r2});
    this.state = {
      dataSource: ds.cloneWithRows([])
    };

    Notificare.fetchInbox(null, 0, 100, (error, inboxItems) => {
        if (!error) {
          console.log(inboxItems);
          this.setState({
            dataSource : this.state.dataSource.cloneWithRows(inboxItems)
          });
        }
    });

  }

  componentWillMount() {

    Notificare.launch();

    this.eventEmitter.addListener('onReady', (data) => {
      console.log(data);
      Notificare.registerForNotifications();
    });

    this.eventEmitter.addListener('didRegisterDevice',(data) => {
      Notificare.fetchTags((error, tags) => {
        if (error) {
          console.error(error);
        } else {
        console.log(tags);
        }
      });
    });

    this.eventEmitter.addListener('didLoadStore',(data) => {
        console.log(data);
    });

    this.eventEmitter.addListener('onNotificationClicked',(data) => {
        Notificare.openNotification(data);
    });

    this.eventEmitter.addListener('onNotificationReceived',(data) => {
        console.log(data);
    });

    this.eventEmitter.addListener('didUpdateBadge',(data) => {
        console.log(data);
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
