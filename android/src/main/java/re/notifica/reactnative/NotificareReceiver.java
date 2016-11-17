package re.notifica.reactnative;

import android.net.Uri;
import android.os.Bundle;

import com.facebook.react.bridge.Arguments;
import com.facebook.react.bridge.WritableMap;

import re.notifica.model.NotificareNotification;
import re.notifica.push.gcm.DefaultIntentReceiver;


public class NotificareReceiver extends DefaultIntentReceiver {

    private static final String TAG = NotificareReceiver.class.getSimpleName();

    @Override
    public void onNotificationOpenRegistered(NotificareNotification notification, Boolean handled) {
        WritableMap payload = Arguments.createMap();
        WritableMap message = Arguments.createMap();
        message.putString("id", notification.getNotificationId());
        payload.putMap("notification", message);
        NotificareEventEmitter.getInstance().sendEvent("didOpenNotification", payload, true);
    }

    @Override
    public void onUrlClicked(Uri urlClicked, Bundle extras) {
        WritableMap map = Arguments.fromBundle(extras);
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

}
