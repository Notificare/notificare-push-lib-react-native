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
    }

    componentDidMount() {

        console.log("componentDidMount");

        Notificare.launch();

        this.eventEmitter.addListener('ready', async (data) => {
            console.log(data);
            console.log(await Notificare.fetchDevice());
            Notificare.registerForNotifications();
            Notificare.startLocationUpdates();
        });

        this.eventEmitter.addListener('deviceRegistered',async (data) => {
            console.log(data);

            this.userNotificationSettings();

            console.log(await Notificare.fetchTags());
            await Notificare.addTag("react-native");

        });


        this.eventEmitter.addListener('urlClickedInNotification',(data) => {
            console.log(data);
        });

        this.eventEmitter.addListener('remoteNotificationReceivedInBackground',(data) => {
            console.log(data);
            Notificare.presentNotification(data);
        });

        this.eventEmitter.addListener('remoteNotificationReceivedInForeground',(data) => {
            console.log(data);
        });

        this.eventEmitter.addListener('inboxLoaded',(data) => {
            console.log(data);
            this.reloadInbox();
        });

    }

    async userNotificationSettings() {
        try {
            console.log(await Notificare.fetchNotificationSettings());
        } catch (e) {
            console.error(e);
        }
    }

    async reloadInbox() {
        try {
            this.setState({dataSource : await Notificare.fetchInbox()});
        } catch (e) {
            console.error(e);
        }
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
