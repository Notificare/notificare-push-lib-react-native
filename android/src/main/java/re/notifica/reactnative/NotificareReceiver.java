package re.notifica.reactnative;

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
        super.onNotificationReceived(alert, notificationId, inboxItemId, extras);
    }

    @Override
    public void onNotificationOpened(String alert, String notificationId, @Nullable String inboxItemId, Bundle extras) {
        super.onNotificationOpened(alert, notificationId, inboxItemId, extras);
    }

    @Override
    public void onNotificationOpenRegistered(NotificareNotification notification, Boolean handled) {
        Log.d(TAG, "Notification with type " + notification.getType() + " was opened, handled by SDK: " + handled);
    }

    @Override
    public void onUrlClicked(Uri urlClicked, Bundle extras) {
        ReadableMap map = Arguments.fromBundle(extras);
        NotificareEventEmitter.getInstance().sendEvent("onUrlClicked", map);
    }

    @Override
    public void onRegistrationFinished(String deviceId) {

        Bundle messageBundle = new Bundle();
        messageBundle.putString("device", deviceId);
        ReadableMap map = Arguments.fromBundle(messageBundle);

        NotificareEventEmitter.getInstance().sendEvent("didRegisterDevice", map);
    }

}
