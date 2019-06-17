package re.notifica.reactnative;

import android.net.Uri;
import android.os.Bundle;

import com.facebook.react.bridge.Arguments;
import com.facebook.react.bridge.WritableMap;

import re.notifica.Notificare;
import re.notifica.app.DefaultIntentReceiver;
import re.notifica.model.NotificareDevice;
import re.notifica.model.NotificareNotification;


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
        NotificareEventEmitter.getInstance().sendEvent("urlClickedInNotification", map, true);
    }

    @Override
    public void onReady() {
        // Event is emitted by the onReady listener in the module
        // Check if notifications are enabled, by default they are not.
        if (Notificare.shared().isNotificationsEnabled()) {
            Notificare.shared().enableNotifications();
        }
        // Check if location updates are enabled, by default they are not.
        if (Notificare.shared().isLocationUpdatesEnabled()) {
            Notificare.shared().enableLocationUpdates();
        }
    }

    @Override
    public void onDeviceRegistered(NotificareDevice device) {
        NotificareEventEmitter.getInstance().sendEvent("deviceRegistered", NotificareUtils.mapDevice(device), true);
    }

}
