package re.notifica.reactnative;

import android.net.Uri;
import android.os.Bundle;
import android.support.annotation.Nullable;
import android.util.Log;

import com.facebook.react.bridge.Arguments;
import com.facebook.react.bridge.ReadableMap;
import com.facebook.react.bridge.WritableArray;
import com.facebook.react.bridge.WritableMap;

import org.json.JSONObject;

import java.util.HashMap;

import re.notifica.Notificare;
import re.notifica.model.NotificareAction;
import re.notifica.model.NotificareContent;
import re.notifica.model.NotificareNotification;
import re.notifica.model.NotificareUserDataField;
import re.notifica.push.gcm.DefaultIntentReceiver;


public class NotificareReceiver extends DefaultIntentReceiver {

    private static final String TAG = NotificareReceiver.class.getSimpleName();

    @Override
    public void onNotificationReceived(String alert, String notificationId, @Nullable String inboxItemId, Bundle extras) {

        Bundle messageBundle = extras;
        messageBundle.putString("alert", alert);
        messageBundle.putString("notificationId", notificationId);
        if (inboxItemId != null) {
            messageBundle.putString("inboxItemId", inboxItemId);
        }
        ReadableMap map = Arguments.fromBundle(messageBundle);

        NotificareEventEmitter.getInstance().sendEvent("onNotificationReceived", map);

        super.onNotificationReceived(alert, notificationId, inboxItemId, extras);
    }

    @Override
    public void onNotificationOpened(String alert, String notificationId, @Nullable String inboxItemId, Bundle extras) {

        NotificareNotification theMessage = extras.getParcelable(Notificare.INTENT_EXTRA_NOTIFICATION);
        WritableMap payload = Arguments.createMap();
        WritableMap notification = Arguments.createMap();
        notification.putString("id", theMessage.getNotificationId());
        if (inboxItemId != null) {
            notification.putString("inboxItemId", inboxItemId);
        }
        notification.putString("message", theMessage.getMessage());
        notification.putString("title", theMessage.getTitle());
        notification.putString("subtitle", theMessage.getSubtitle());
        notification.putString("type", theMessage.getType());
        notification.putString("time", theMessage.getTime().toString());


        if (theMessage.getExtra() != null) {
            WritableMap theExtra = Arguments.createMap();
            for(HashMap.Entry<String, String> prop : theMessage.getExtra().entrySet()){
                theExtra.putString(prop.getKey(), prop.getValue());
            }
            notification.putMap("extra", theExtra);
        }

        if (theMessage.getContent().size() > 0) {
            WritableArray theContent = Arguments.createArray();
            for(NotificareContent c : theMessage.getContent()){
                WritableMap content = Arguments.createMap();
                content.putString("type", c.getType());
                content.putString("data", c.getData().toString());
                theContent.pushMap(content);
            }
            notification.putArray("content", theContent);
        }

        if (theMessage.getActions().size() > 0) {
            WritableArray theActions = Arguments.createArray();
            for(NotificareAction a : theMessage.getActions()){
                WritableMap action = Arguments.createMap();
                action.putString("label", a.getLabel());
                action.putString("type", a.getType());
                action.putString("target", a.getTarget());
                action.putBoolean("camera", a.getCamera());
                action.putBoolean("keyboard", a.getKeyboard());
                theActions.pushMap(action);
            }
            notification.putArray("actions", theActions);
        }

        payload.putMap("notification", notification);
        NotificareEventEmitter.getInstance().sendEvent("onNotificationOpened", payload);
        //super.onNotificationOpened(alert, notificationId, inboxItemId, extras);
    }

    @Override
    public void onNotificationOpenRegistered(NotificareNotification notification, Boolean handled) {
        WritableMap payload = Arguments.createMap();
        WritableMap message = Arguments.createMap();
        message.putString("id", notification.getNotificationId());
        payload.putMap("notification", message);
        NotificareEventEmitter.getInstance().sendEvent("didOpenNotification", payload);
    }

    @Override
    public void onUrlClicked(Uri urlClicked, Bundle extras) {
        WritableMap map = Arguments.fromBundle(extras);
        map.putString("url", urlClicked.toString());
        NotificareEventEmitter.getInstance().sendEvent("didClickURL", map);
    }

    @Override
    public void onReady() {
        WritableMap payload = Arguments.createMap();
        WritableMap info = Arguments.createMap();
        info.putString("id", Notificare.shared().getApplicationInfo().getId());
        info.putString("name", Notificare.shared().getApplicationInfo().getName());

        WritableArray theServices = Arguments.createArray();
        for (HashMap.Entry<String, Boolean> services : Notificare.shared().getApplicationInfo().getServices().entrySet()){
            WritableMap s = Arguments.createMap();
            s.putBoolean(services.getKey(), services.getValue());
            theServices.pushMap(s);
        }
        info.putArray("services", theServices);

        WritableArray theActionCategories = Arguments.createArray();
        for (HashMap.Entry<String, JSONObject> services : Notificare.shared().getApplicationInfo().getActionCategories().entrySet()){
            WritableMap c = Arguments.createMap();
            c.putString(services.getKey(), services.getValue().toString());
            theActionCategories.pushMap(c);
        }
        info.putArray("actionCategories", theActionCategories);

        WritableMap inboxConfig = Arguments.createMap();
        inboxConfig.putBoolean("autoBadge", Notificare.shared().getApplicationInfo().getInboxConfig().getAutoBadge());
        inboxConfig.putBoolean("useInbox", Notificare.shared().getApplicationInfo().getInboxConfig().getUseInbox());
        info.putMap("inboxConfig", inboxConfig);

        WritableMap regionConfig = Arguments.createMap();
        regionConfig.putString("proximityUUID", Notificare.shared().getApplicationInfo().getRegionConfig().getProximityUUID());
        info.putMap("regionConfig", regionConfig);


        WritableArray userDataFields = Arguments.createArray();
        for (HashMap.Entry<String, NotificareUserDataField> fields : Notificare.shared().getApplicationInfo().getUserDataFields().entrySet()){
            WritableMap c = Arguments.createMap();
            c.putString(fields.getKey(), fields.getValue().toString());
            userDataFields.pushMap(c);
        }
        info.putArray("userDataFields", userDataFields);

        payload.putMap("application", info);
        NotificareEventEmitter.getInstance().sendEvent("onReady", payload);
    }

    @Override
    public void onRegistrationFinished(String deviceId) {
        Bundle messageBundle = new Bundle();
        messageBundle.putString("device", deviceId);
        ReadableMap map = Arguments.fromBundle(messageBundle);
        NotificareEventEmitter.getInstance().sendEvent("didReceiveDeviceToken", map);
    }

}
