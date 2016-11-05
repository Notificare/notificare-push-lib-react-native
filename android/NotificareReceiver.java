package com.awesomeproject;

import android.content.Intent;
import android.os.Bundle;
import android.support.annotation.Nullable;
import android.util.Log;

import java.util.List;

import re.notifica.Notificare;
import re.notifica.NotificareCallback;
import re.notifica.NotificareError;
import re.notifica.model.NotificareInboxItem;
import re.notifica.model.NotificareNotification;
import re.notifica.model.NotificareTimeOfDayRange;
import re.notifica.push.gcm.DefaultIntentReceiver;



public class NotificareReceiver extends DefaultIntentReceiver {

    private static final String TAG = NotificareReceiver.class.getSimpleName();

    @Override
    public void onNotificationReceived(String alert, String notificationId, final String inboxItemId, Bundle extras) {
        super.onNotificationReceived(alert, notificationId, inboxItemId, extras);
    }

    @Override
    public void onNotificationOpened(String alert, String notificationId, @Nullable String inboxItemId, Bundle extras) {
        NotificareNotification notification = extras.getParcelable(Notificare.INTENT_EXTRA_NOTIFICATION);

        super.onNotificationOpened(alert, notificationId, inboxItemId, extras);
    }

    @Override
    public void onReady() {


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
