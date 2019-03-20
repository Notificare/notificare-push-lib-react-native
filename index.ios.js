/**
 * Sample React Native App
 * https://github.com/facebook/react-native
 * @flow
 */

import React, { Component } from 'react';
import {
    AppRegistry,
    FlatList,
    StyleSheet,
    Text,
    NativeModules,
    NativeEventEmitter,
    TouchableHighlight,
    View
} from 'react-native';


const Notificare = NativeModules.NotificareReactNativeIOS;

export default class App extends Component {

    constructor(props){
        super(props);
        this.eventEmitter = new NativeEventEmitter(Notificare);
        this.state = {
            dataSource: []
        };

        this._reloadInbox();

    }

    componentWillMount() {

        console.log("componentWillMount");

        Notificare.launch();

        this.eventEmitter.addListener('ready', (data) => {
            console.log(data);
        Notificare.registerForNotifications();
    });

        this.eventEmitter.addListener('didReceiveDeviceToken',(data) => {
            console.log(data);

        Notificare.registerDevice(data.device, null, null, (error, data) => {

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

            Notificare.startLocationUpdates();

        }
    });
    });


        this.eventEmitter.addListener('willOpenURL',(data) => {
            console.log(data);
    });

        this.eventEmitter.addListener('notificationOpened',(data) => {
            console.log(data);
        Notificare.openNotification(data);
    });

        this.eventEmitter.addListener('notificationReceived',(data) => {
            console.log(data);
    });

        this.eventEmitter.addListener('badge',(data) => {
            console.log(data);
        this._reloadInbox();
    });

        this.eventEmitter.addListener('systemPush',(data) => {
            console.log(data);
    });

        this.eventEmitter.addListener('willOpenNotification',(data) => {
            console.log(data);
    });

        this.eventEmitter.addListener('didOpenNotification',(data) => {
            console.log(data);
    });

        this.eventEmitter.addListener('didClickURL',(data) => {
            console.log(data);
    });

        this.eventEmitter.addListener('didCloseNotification',(data) => {
            console.log(data);
    });

        this.eventEmitter.addListener('didFailToOpenNotification',(data) => {
            console.log(data);
    });

        this.eventEmitter.addListener('willExecuteAction',(data) => {
            console.log(data);
    });

        this.eventEmitter.addListener('didExecuteAction',(data) => {
            console.log(data);
    });

        this.eventEmitter.addListener('shouldPerformSelectorWithURL',(data) => {
            console.log(data);
    });

        this.eventEmitter.addListener('didNotExecuteAction',(data) => {
            console.log(data);
    });

        this.eventEmitter.addListener('didFailToExecuteAction',(data) => {
            console.log(data);
    });


        this.eventEmitter.addListener('didReceiveLocationServiceAuthorizationStatus',(data) => {
            console.log(data);
    });

        this.eventEmitter.addListener('didFailToStartLocationServiceWithError',(data) => {
            console.log(data);
    });

        this.eventEmitter.addListener('didUpdateLocations',(data) => {
            console.log(data);
    });

        this.eventEmitter.addListener('didStartMonitoringForRegion',(data) => {
            console.log(data);
    });

        this.eventEmitter.addListener('monitoringDidFailForRegion',(data) => {
            console.log(data);
    });

        this.eventEmitter.addListener('didDetermineState',(data) => {
            console.log(data);
    });

        this.eventEmitter.addListener('didEnterRegion',(data) => {
            console.log(data);
    });

        this.eventEmitter.addListener('didExitRegion',(data) => {
            console.log(data);
    });

        this.eventEmitter.addListener('rangingBeaconsDidFailForRegion',(data) => {
            console.log(data);
    });

        this.eventEmitter.addListener('didRangeBeacons',(data) => {
            console.log(data);
    });

        this.eventEmitter.addListener('didLoadStore',(data) => {
            console.log('didLoadStore' , data);
    });

        this.eventEmitter.addListener('didFailToLoadStore',(data) => {
            console.log(data);
    });

        this.eventEmitter.addListener('didFailProductTransaction',(data) => {
            console.log(data);
    });

        this.eventEmitter.addListener('didCompleteProductTransaction',(data) => {
            console.log(data);
    });

        this.eventEmitter.addListener('didRestoreProductTransaction',(data) => {
            console.log(data);
    });

        this.eventEmitter.addListener('didStartDownloadContent',(data) => {
            console.log(data);
    });

        this.eventEmitter.addListener('didPauseDownloadContent',(data) => {
            console.log(data);
    });

        this.eventEmitter.addListener('didCancelDownloadContent',(data) => {
            console.log(data);
    });

        this.eventEmitter.addListener('didReceiveProgressDownloadContent',(data) => {
            console.log(data);
    });

        this.eventEmitter.addListener('didFailDownloadContent',(data) => {
            console.log(data);
    });

        this.eventEmitter.addListener('didFinishDownloadContent',(data) => {
            console.log(data);
    });

        this.eventEmitter.addListener('didChangeAccountNotification',(data) => {
            console.log(data);
    });

        this.eventEmitter.addListener('didFailToRequestAccessNotification',(data) => {
            console.log(data);
    });

        this.eventEmitter.addListener('didValidateAccount',(data) => {
            console.log(data);
    });

        this.eventEmitter.addListener('didFailToValidateAccount',(data) => {
            console.log(data);
    });

        this.eventEmitter.addListener('didReceiveResetPasswordToken',(data) => {
            console.log(data);
    });

    }

    _reloadInbox (){
        Notificare.fetchInbox(null, 0, 100, (error, data) => {
            if (!error) {
            console.log(data);
            this.setState({
                dataSource : data.inbox
            });
        }
    });
    }


    render() {
        return (
            <View style={styles.view}>
                <FlatList
                    data={this.state.dataSource}
                    renderItem={this.renderRow}
                    keyExtractor={(item, index) => index.toString()}
                />
            </View>
        );
    }

    renderRow ({item}) {
        return (
            <TouchableHighlight>
                <View>
                    <View style={styles.row}>
                        <Text style={styles.text}>
                            {item.message}
                        </Text>
                            <Text style={styles.text}>
                            {item.time}
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
        backgroundColor: '#F6F6F6'
    },
    text: {
        flex: 1,
        fontSize: 12,
    }
});
