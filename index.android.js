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
    Linking,
    NativeModules,
    DeviceEventEmitter,
    TouchableHighlight,
    View
} from 'react-native';


const Notificare = NativeModules.NotificareReactNativeAndroid;

export default class App extends Component {

    constructor(props){
        super(props);
        this.state = {
            dataSource: []
        };
    }

    componentWillMount() {

        console.log("componentWillMount");

        Notificare.launch();

        Linking.getInitialURL().then((url) => {
            if (url) {
                this._handleOpenURL(url);
            }
        }).catch(err => console.error('An error occurred', err));

        Linking.addEventListener('url', this._handleOpenURL);

        DeviceEventEmitter.addListener('ready', async (data) => {
            console.log(data);
            console.log(await Notificare.fetchDevice());
            Notificare.registerForNotifications();
            console.log(await Notificare.fetchTags());
            await Notificare.addTag("react-native");
            const granted = await PermissionsAndroid.request(PermissionsAndroid.PERMISSIONS.ACCESS_FINE_LOCATION, {
                'title': 'Location Permission',
                'message': 'We need your location so we can send you relevant push notifications'
            });
            if (granted) {
                Notificare.startLocationUpdates()
            }
            try {
                await Notificare.login("joris@notifica.re", "Test123!")
            } catch (err) {
                console.warn(err.message);
            }
        });

        DeviceEventEmitter.addListener('urlClickedInNotification', (data) => {
            console.log(data);
        });

        DeviceEventEmitter.addListener('deviceRegistered', (data) => {
            console.log(data);
        });

        DeviceEventEmitter.addListener('remoteNotificationReceivedInBackground', (data) => {
            console.log(data);
            Notificare.presentNotification(data);
        });

        DeviceEventEmitter.addListener('remoteNotificationReceivedInForeground', (data) => {
            console.log(data);
        });

        DeviceEventEmitter.addListener('badgeUpdated', (data) => {
            console.log(data);
        });

        DeviceEventEmitter.addListener('inboxLoaded', (data) => {
            console.log(data);
            this.setState({
                dataSource: data
            });
        });

        DeviceEventEmitter.addListener('activationTokenReceived', async (data) => {
            console.log(data);
            if (data && data.token) {
                try {
                    await Notificare.validateAccount(data.token);
                } catch (err) {
                    console.warn(err.message);
                }
            }
        });

        DeviceEventEmitter.addListener('resetPasswordTokenReceived', (data) => {
            console.log(data);
        });

    }

    componentWillUnmount() {
        console.log('componentWillUnmount');
        Notificare.unmount();
        Linking.removeEventListener('url', this._handleOpenURL);
        DeviceEventEmitter.removeAllListeners();
    }

    _handleOpenURL(url) {
        console.log("Deeplink URL: " + url);
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
            <TouchableHighlight onPress={() => Notificare.presentInboxItem(item)}>
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
