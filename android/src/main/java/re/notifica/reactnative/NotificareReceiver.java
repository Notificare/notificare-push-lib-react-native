package re.notifica.reactnative;

import android.net.Uri;
import android.os.Bundle;

import com.facebook.react.bridge.Arguments;
import com.facebook.react.bridge.WritableMap;

import re.notifica.Notificare;
import re.notifica.model.NotificareNotification;
import re.notifica.push.gcm.DefaultIntentReceiver;


public class NotificareReceiver extends DefaultIntentReceiver {

    private static final String TAG = NotificareReceiver.class.getSimpleName();

    @Override
    public void onUrlClicked(Uri urlClicked, Bundle extras) {
        WritableMap map = Arguments.createMap();
        if (extras.containsKey(Notificare.INTENT_EXTRA_NOTIFICATION)) {
            NotificareNotification notification = extras.getParcelable(Notificare.INTENT_EXTRA_NOTIFICATION);
            if (notification != null) {
                map.putMap("notification", NotificareUtils.mapNotification(notification));
            }
        }
        map.putString("url", urlClicked.toString());
        NotificareEventEmitter.getInstance().sendEvent("didClickURL", map, true);
    }

    @Override
    public void onReady() {
        // This is handled by making the module an onReadyListener
    }

    @Override
    public void onRegistrationFinished(String deviceId) {
        WritableMap map = Arguments.createMap();
        map.putString("device", deviceId);
        NotificareEventEmitter.getInstance().sendEvent("didReceiveDeviceToken", map, true);
    }


    @Override
    public void onNotificationOpened(String alert, final String notificationId, final String inboxItemId, Bundle extras) {
        super.onNotificationOpened(alert, notificationId, inboxItemId, extras);
    }
}
