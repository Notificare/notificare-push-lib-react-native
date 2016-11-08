package com.awesomeproject;

import android.content.Intent;
import android.os.Bundle;
import android.support.annotation.Nullable;
import android.util.Log;
import android.net.Uri;

import java.util.List;

import re.notifica.Notificare;
import re.notifica.NotificareCallback;
import re.notifica.NotificareError;
import re.notifica.model.NotificareInboxItem;
import re.notifica.model.NotificareNotification;
import re.notifica.model.NotificareTimeOfDayRange;
import re.notifica.push.gcm.DefaultIntentReceiver;

import com.facebook.react.bridge.Arguments;
import com.facebook.react.bridge.ReadableMap;

public class NotificareReceiver extends DefaultIntentReceiver {

    private static final String TAG = NotificareReceiver.class.getSimpleName();

    @Override
    public void onNotificationReceived(String alert, String notificationId, final String inboxItemId, Bundle extras) {

        Bundle messageBundle = extras;
        messageBundle.putString("alert", alert);
        messageBundle.putString("notificationId", notificationId);
        messageBundle.putString("inboxItemId", inboxItemId);
        ReadableMap map = Arguments.fromBundle(messageBundle);

        NotificareEventEmitter.getInstance().sendEvent("onNotificationReceived", map);

        super.onNotificationReceived(alert, notificationId, inboxItemId, extras);
    }

    @Override
    public void onNotificationOpened(String alert, String notificationId, @Nullable String inboxItemId, Bundle extras) {
        NotificareNotification notification = extras.getParcelable(Notificare.INTENT_EXTRA_NOTIFICATION);

        super.onNotificationOpened(alert, notificationId, inboxItemId, extras);
    }

    @Override
    public void onNotificationOpenRegistered(NotificareNotification notification, Boolean handled) {
        Log.d(TAG, "Notification with type " + notification.getType() + " was opened, handled by SDK: " + handled);
    }

    @Override
    public void onUrlClicked(Uri urlClicked, Bundle extras) {
        Log.i(TAG, "URL was clicked: " + urlClicked);
        NotificareNotification notification = extras.getParcelable(Notificare.INTENT_EXTRA_NOTIFICATION);
        if (notification != null) {
            Log.i(TAG, "URL was clicked for \"" + notification.getMessage() + "\"");
        }
    }

    @Override
    public void onReady() {

        NotificareEventEmitter.getInstance().sendEvent("onReady", null);

    }

    @Override
    public void onRegistrationFinished(String deviceId) {
        // Register as a device
        Notificare.shared().registerDevice(deviceId, new NotificareCallback<String>() {
            @Override
            public void onSuccess(String result) {

            }

            @Override
            public void onError(NotificareError error) {
                //Log.e(TAG, "Error registering device", error);
            }
        });
    }

}
