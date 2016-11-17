package re.notifica.reactnative;

import com.facebook.react.bridge.Arguments;
import com.facebook.react.bridge.ReadableMap;
import com.facebook.react.bridge.ReadableMapKeySetIterator;
import com.facebook.react.bridge.ReadableType;
import com.facebook.react.bridge.WritableArray;
import com.facebook.react.bridge.WritableMap;

import java.util.HashMap;
import java.util.Map;

import javax.annotation.Nullable;

import re.notifica.model.NotificareAction;
import re.notifica.model.NotificareApplicationInfo;
import re.notifica.model.NotificareAsset;
import re.notifica.model.NotificareContent;
import re.notifica.model.NotificareInboxItem;
import re.notifica.model.NotificareNotification;
import re.notifica.model.NotificareTimeOfDayRange;
import re.notifica.util.ISODateFormatter;


public class NotificareUtils {

    /**
     * Create a Map from ReadableMap
     * @param data
     * @return
     */
    public static Map<String, Object> createMap(@Nullable ReadableMap data) {

        if (data == null) {
            return null;
        }

        Map<String, Object> map = new HashMap<>();
        ReadableMapKeySetIterator iterator = data.keySetIterator();


        while (iterator.hasNextKey()) {
            String key = iterator.nextKey();
            ReadableType readableType = data.getType(key);
            switch (readableType) {
                case Null:
                    map.put(key, null);
                    break;
                case Boolean:
                    map.put(key, data.getBoolean(key));
                    break;
                case Number:
                    map.put(key, data.getDouble(key));
                    break;
                case String:
                    map.put(key, data.getString(key));
                    break;
                case Map:
                    map.put(key, createMap(data.getMap(key)));
                    break;
                default:
                    break;
            }
        }

        return map;
    }

    public static WritableMap mapApplicationInfo(NotificareApplicationInfo notificareApplicationInfo) {
        WritableMap infoMap = Arguments.createMap();
        infoMap.putString("id", notificareApplicationInfo.getId());
        infoMap.putString("name", notificareApplicationInfo.getName());

        WritableMap servicesMap = Arguments.createMap();
        for (String key : notificareApplicationInfo.getServices().keySet()){
            servicesMap.putBoolean(key, notificareApplicationInfo.getServices().get(key));
        }
        infoMap.putMap("services", servicesMap);

        if (notificareApplicationInfo.getInboxConfig() != null) {
            WritableMap inboxConfigMap = Arguments.createMap();
            inboxConfigMap.putBoolean("autoBadge", notificareApplicationInfo.getInboxConfig().getAutoBadge());
            inboxConfigMap.putBoolean("useInbox", notificareApplicationInfo.getInboxConfig().getUseInbox());
            infoMap.putMap("inboxConfig", inboxConfigMap);
        }

        if (notificareApplicationInfo.getRegionConfig() != null) {
            WritableMap regionConfigMap = Arguments.createMap();
            regionConfigMap.putString("proximityUUID", notificareApplicationInfo.getRegionConfig().getProximityUUID());
            infoMap.putMap("regionConfig", regionConfigMap);
        }


        WritableArray userDataFieldsArray = Arguments.createArray();
        for (String key : notificareApplicationInfo.getUserDataFields().keySet()){
            WritableMap userDataFieldMap = Arguments.createMap();
            userDataFieldMap.putString("key", key);
            userDataFieldMap.putString("label", notificareApplicationInfo.getUserDataFields().get(key).getLabel());
            userDataFieldsArray.pushMap(userDataFieldMap);
        }
        infoMap.putArray("userDataFields", userDataFieldsArray);
        return infoMap;
    }

    public static WritableMap mapNotification(NotificareNotification notification) {
        WritableMap notificationMap = Arguments.createMap();
        notificationMap.putString("id", notification.getNotificationId());
        notificationMap.putString("message", notification.getMessage());
        notificationMap.putString("title", notification.getTitle());
        notificationMap.putString("subtitle", notification.getSubtitle());
        notificationMap.putString("type", notification.getType());
        notificationMap.putString("time", ISODateFormatter.format(notification.getTime()));


        if (notification.getExtra() != null) {
            WritableMap extraMap = Arguments.createMap();
            for (HashMap.Entry<String, String> prop : notification.getExtra().entrySet()) {
                extraMap.putString(prop.getKey(), prop.getValue());
            }
            notificationMap.putMap("extra", extraMap);
        }

        if (notification.getContent().size() > 0) {
            WritableArray contentArray = Arguments.createArray();
            for (NotificareContent c : notification.getContent()) {
                WritableMap contentMap = Arguments.createMap();
                contentMap.putString("type", c.getType());
                contentMap.putString("data", c.getData().toString());
                contentArray.pushMap(contentMap);
            }
            notificationMap.putArray("content", contentArray);
        }

        if (notification.getActions().size() > 0) {
            WritableArray actionsArray = Arguments.createArray();
            for (NotificareAction a : notification.getActions()) {
                WritableMap actionMap = Arguments.createMap();
                actionMap.putString("label", a.getLabel());
                actionMap.putString("type", a.getType());
                actionMap.putString("target", a.getTarget());
                actionMap.putBoolean("camera", a.getCamera());
                actionMap.putBoolean("keyboard", a.getKeyboard());
                actionsArray.pushMap(actionMap);
            }
            notificationMap.putArray("actions", actionsArray);
        }

        return notificationMap;

    }

    public static WritableMap mapAsset(NotificareAsset asset) {
        WritableMap assetMap = Arguments.createMap();

        assetMap.putString("title", asset.getTitle());
        assetMap.putString("description", asset.getDescription());
        assetMap.putString("url", asset.getUrl().toString());

        WritableMap theMeta = Arguments.createMap();
        theMeta.putString("originalFileName", asset.getOriginalFileName());
        theMeta.putString("key", asset.getKey());
        theMeta.putString("contentType", asset.getContentType());
        theMeta.putInt("contentLength", asset.getContentLength());
        assetMap.putMap("metaData", theMeta);

        WritableMap theButton = Arguments.createMap();
        theButton.putString("label", asset.getButtonLabel());
        theButton.putString("action", asset.getButtonAction());
        assetMap.putMap("button", theButton);

        return assetMap;
    }

    public static WritableMap mapTimeOfDayRange(NotificareTimeOfDayRange notificareTimeOfDayRange) {
        WritableMap timeOfDayRangeMap = Arguments.createMap();
        timeOfDayRangeMap.putString("start", notificareTimeOfDayRange.getStart().toString());
        timeOfDayRangeMap.putString("end", notificareTimeOfDayRange.getEnd().toString());
        return timeOfDayRangeMap;
    }

    public static WritableMap mapInboxItem(NotificareInboxItem notificareInboxItem) {
        WritableMap inboxItemMap = Arguments.createMap();
        inboxItemMap.putString("inboxId", notificareInboxItem.getItemId());
        inboxItemMap.putString("notification", notificareInboxItem.getNotification().getNotificationId());
        inboxItemMap.putString("message", notificareInboxItem.getNotification().getMessage());
        inboxItemMap.putString("time", ISODateFormatter.format(notificareInboxItem.getTimestamp()));
        inboxItemMap.putBoolean("opened", notificareInboxItem.getStatus());
        return inboxItemMap;
    }

}
