package re.notifica.reactnative;

import com.facebook.react.bridge.Arguments;
import com.facebook.react.bridge.ReadableMap;
import com.facebook.react.bridge.ReadableMapKeySetIterator;
import com.facebook.react.bridge.ReadableType;
import com.facebook.react.bridge.WritableArray;
import com.facebook.react.bridge.WritableMap;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import java.util.HashMap;
import java.util.Iterator;
import java.util.List;
import java.util.Map;

import javax.annotation.Nullable;

import re.notifica.Notificare;
import re.notifica.model.NotificareAction;
import re.notifica.model.NotificareApplicationInfo;
import re.notifica.model.NotificareAsset;
import re.notifica.model.NotificareAttachment;
import re.notifica.model.NotificareBeacon;
import re.notifica.model.NotificareContent;
import re.notifica.model.NotificareCoordinates;
import re.notifica.model.NotificareDevice;
import re.notifica.model.NotificareInboxItem;
import re.notifica.model.NotificareNotification;
import re.notifica.model.NotificarePass;
import re.notifica.model.NotificarePassRedemption;
import re.notifica.model.NotificarePoint;
import re.notifica.model.NotificarePolygon;
import re.notifica.model.NotificareProduct;
import re.notifica.model.NotificareRegion;
import re.notifica.model.NotificareScannable;
import re.notifica.model.NotificareTimeOfDayRange;
import re.notifica.model.NotificareUser;
import re.notifica.model.NotificareUserPreference;
import re.notifica.model.NotificareUserPreferenceOption;
import re.notifica.model.NotificareUserSegment;
import re.notifica.util.ISODateFormatter;
import re.notifica.util.Log;


public class NotificareUtils {

    public static final String TAG = NotificareUtils.class.getSimpleName();
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

    public static WritableArray mapJSON(JSONArray json) {
        if (json != null) {
            WritableArray writableArray = Arguments.createArray();
            try {
                for (int i = 0; i < json.length(); i++) {
                    Object value = json.get(i);
                    if (value instanceof Float || value instanceof Double) {
                        writableArray.pushDouble(json.getDouble(i));
                    } else if (value instanceof Number) {
                        writableArray.pushInt(json.getInt(i));
                    } else if (value instanceof String) {
                        writableArray.pushString(json.getString(i));
                    } else if (value instanceof JSONObject) {
                        writableArray.pushMap(mapJSON(json.getJSONObject(i)));
                    } else if (value instanceof JSONArray) {
                        writableArray.pushArray(mapJSON(json.getJSONArray(i)));
                    } else if (value == JSONObject.NULL) {
                        writableArray.pushNull();
                    }
                }
            } catch (JSONException e) {
                // fail silently
            }
            return writableArray;
        } else {
            return null;
        }
    }

    public static WritableMap mapJSON(JSONObject json) {
        if (json != null) {
            WritableMap writableMap = Arguments.createMap();
            Iterator<String> iterator = json.keys();
            try {
                while (iterator.hasNext()) {
                    String key = iterator.next();
                    Object value = json.get(key);
                    if (value instanceof Float || value instanceof Double) {
                        writableMap.putDouble(key, json.getDouble(key));
                    } else if (value instanceof Number) {
                        writableMap.putInt(key, json.getInt(key));
                    } else if (value instanceof String) {
                        writableMap.putString(key, json.getString(key));
                    } else if (value instanceof JSONObject) {
                        writableMap.putMap(key, mapJSON(json.getJSONObject(key)));
                    } else if (value instanceof JSONArray) {
                        writableMap.putArray(key, mapJSON(json.getJSONArray(key)));
                    } else if (value == JSONObject.NULL) {
                        writableMap.putNull(key);
                    }
                }
            } catch (JSONException e) {
                // fail silently
            }
            return writableMap;
        } else {
            return null;
        }
    }

    public static WritableMap mapApplicationInfo(NotificareApplicationInfo notificareApplicationInfo) {
        WritableMap infoMap = Arguments.createMap();
        infoMap.putString("id", notificareApplicationInfo.getId());
        infoMap.putString("name", notificareApplicationInfo.getName());

        WritableMap servicesMap = Arguments.createMap();
        for (String key : notificareApplicationInfo.getServices().keySet()) {
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

    public static WritableMap mapDevice(NotificareDevice device) {
        WritableMap deviceMap = Arguments.createMap();
        deviceMap.putString("deviceID", device.getDeviceId());
        deviceMap.putString("userID", device.getUserId());
        deviceMap.putString("userName", device.getUserName());
        deviceMap.putDouble("timezone", device.getTimeZoneOffset());
        deviceMap.putString("osVersion", device.getOsVersion());
        deviceMap.putString("sdkVersion", device.getSdkVersion());
        deviceMap.putString("appVersion", device.getAppVersion());
        deviceMap.putString("deviceString", device.getDeviceString());
        deviceMap.putString("deviceModel", device.getDeviceString());
        deviceMap.putString("countryCode", device.getCountry());
        deviceMap.putString("language", device.getLanguage());
        deviceMap.putString("region", device.getRegion());
        deviceMap.putString("transport", device.getTransport());
        if (!Double.isNaN(device.getLatitude())) {
            deviceMap.putDouble("latitude", device.getLatitude());
        }
        if (!Double.isNaN(device.getLongitude())) {
            deviceMap.putDouble("longitude", device.getLongitude());
        }
        if (!Double.isNaN(device.getAltitude())) {
            deviceMap.putDouble("altitude", device.getAltitude());
        }
        if (!Double.isNaN(device.getSpeed())) {
            deviceMap.putDouble("speed", device.getSpeed());
        }
        if (!Double.isNaN(device.getCourse())) {
            deviceMap.putDouble("course", device.getCourse());
        }
        if (device.getLastActive() != null) {
            deviceMap.putString("lastRegistered", ISODateFormatter.format(device.getLastActive()));
        }
        deviceMap.putString("locationServicesAuthStatus", device.getLocationServicesAuthStatus());
        deviceMap.putBoolean("registeredForNotification", Notificare.shared().isNotificationsEnabled());
        deviceMap.putBoolean("allowedLocationServices", Notificare.shared().isLocationUpdatesEnabled());
        deviceMap.putBoolean("allowedUI", device.getAllowedUI());
        deviceMap.putBoolean("bluetoothEnabled", device.getBluetoothEnabled());
        deviceMap.putBoolean("bluetoothON", device.getBluetoothEnabled());
        return deviceMap;
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

        if (notification.getAttachments().size() > 0) {
            WritableArray attachmentsArray = Arguments.createArray();
            for (NotificareAttachment a : notification.getAttachments()) {
                WritableMap attachmentsMap = Arguments.createMap();
                attachmentsMap.putString("mimeType", a.getMimeType());
                attachmentsMap.putString("uri", a.getUri());
                attachmentsArray.pushMap(attachmentsMap);
            }
            notificationMap.putArray("attachments", attachmentsArray);
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

        notificationMap.putBoolean("partial", notification.isPartial());
        return notificationMap;

    }

    public static NotificareNotification createNotification(ReadableMap notificationMap) {
        if (notificationMap.getBoolean("partial")) {
            return null;
        } else {
            try {
                JSONObject json = new JSONObject(notificationMap.toHashMap());
                if (notificationMap.hasKey("id")) {
                    json.put("_id", notificationMap.getString("id"));
                }
//                if (notificationMap.hasKey("message")) {
//                    json.put("message", notificationMap.getString("message"));
//                }
//                if (notificationMap.hasKey("title")) {
//                    json.put("title", notificationMap.getString("title"));
//                }
//                if (notificationMap.hasKey("subtitle")) {
//                    json.put("subtitle", notificationMap.getString("subtitle"));
//                }
//                if (notificationMap.hasKey("type")) {
//                    json.put("type", notificationMap.getString("type"));
//                }
//                if (notificationMap.hasKey("time")) {
//                    json.put("time", notificationMap.getString("time"));
//                }
//                if (notificationMap.hasKey("partial")) {
//                    json.put("partial", notificationMap.getBoolean("partial"));
//                }
//                if (notificationMap.hasKey("extra")) {
//                    ReadableMap extra = notificationMap.getMap("extra");
//                    JSONObject extraJson = new JSONObject();
//                    while (extra.keySetIterator().hasNextKey()) {
//                        String key = extra.keySetIterator().nextKey();
//                        extraJson.put(key, extra.getString(key));
//                    }
//                    json.put("extra", extraJson);
//                }
//                if (notificationMap.hasKey("attachments")) {
//                    ReadableArray attachments = notificationMap.getArray("attachments");
//                    if (attachments != null) {
//                        JSONArray attachmentsJson = new JSONArray();
//                        for (int i = 0; i < attachments.size(); i++) {
//                            ReadableMap attachment = attachments.getMap(i);
//                            if (attachment != null && attachment.hasKey("mimeType") && attachment.hasKey("uri")) {
//                                JSONObject attachmentJson = new JSONObject();
//                                attachmentJson.put("mimeType", attachment.getString("mimeType"));
//                                attachmentJson.put("uri", attachment.getString("uri"));
//                                attachmentsJson.put(attachmentJson);
//                            }
//                        }
//                        json.put("attachments", attachmentsJson);
//                    }
//                }
//                if (notificationMap.hasKey("content")) {
//                    ReadableArray content = notificationMap.getArray("content");
//                    if (content != null) {
//                        JSONArray contentJson = new JSONArray();
//                        for (int i = 0; i < content.size(); i++) {
//                            ReadableMap contentItem = content.getMap(i);
//                            if (contentItem != null && contentItem.hasKey("type") && contentItem.hasKey("data")) {
//                                JSONObject contentItemJson = new JSONObject();
//                                contentItemJson.put("type", contentItem.getString("type"));
//                                try {
//                                    contentItemJson.put("data", new JSONObject(contentItem.getString("data")));
//                                } catch (JSONException e) {
//                                    contentItemJson.put("data", contentItem.getString("data"));
//                                }
//                                contentJson.put(contentItemJson);
//                            }
//                        }
//                        json.put("content", contentJson);
//                    }
//                }
//                if (notificationMap.hasKey("actions")) {
//                    ReadableArray actions = notificationMap.getArray("actions");
//                    if (actions != null) {
//                        JSONArray actionsJson = new JSONArray();
//                        for (int i = 0; i < actions.size(); i++) {
//                            ReadableMap action = actions.getMap(i);
//                            if (action != null && action.hasKey("label") && action.hasKey("type")) {
//                                JSONObject actionJson = new JSONObject();
//                                actionJson.put("label", action.getString("label"));
//                                actionJson.put("type", action.getString("type"));
//                                if (action.hasKey("target")) {
//                                    actionJson.put("target", action.getString("target"));
//                                }
//                                if (action.hasKey("camera")) {
//                                    actionJson.put("camera", action.getBoolean("camera"));
//                                }
//                                if (action.hasKey("keyboard")) {
//                                    actionJson.put("keyboard", action.getBoolean("keyboard"));
//                                }
//                                actionsJson.put(actionJson);
//                            }
//                        }
//                        json.put("actions", actionsJson);
//                    }
//                }
                return new NotificareNotification(json);
            } catch (JSONException e) {
                Log.e(TAG, e.getMessage());
                return null;
            }
        }
    }

    public static WritableMap mapAsset(NotificareAsset asset) {
        WritableMap assetMap = Arguments.createMap();

        assetMap.putString("assetTitle", asset.getTitle());
        assetMap.putString("assetDescription", asset.getDescription());
        assetMap.putString("assetUrl", asset.getUrl().toString());

        WritableMap theMeta = Arguments.createMap();
        theMeta.putString("originalFileName", asset.getOriginalFileName());
        theMeta.putString("key", asset.getKey());
        theMeta.putString("contentType", asset.getContentType());
        theMeta.putInt("contentLength", asset.getContentLength());
        assetMap.putMap("assetMetaData", theMeta);

        WritableMap theButton = Arguments.createMap();
        theButton.putString("label", asset.getButtonLabel());
        theButton.putString("action", asset.getButtonAction());
        assetMap.putMap("assetButton", theButton);

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
        inboxItemMap.putString("title", notificareInboxItem.getTitle());
        inboxItemMap.putString("subtitle", notificareInboxItem.getSubtitle());
        if (notificareInboxItem.getAttachment() != null) {
            WritableMap attachmentsMap = Arguments.createMap();
            attachmentsMap.putString("mimeType", notificareInboxItem.getAttachment().getMimeType());
            attachmentsMap.putString("uri", notificareInboxItem.getAttachment().getUri());
            inboxItemMap.putMap("attachment", attachmentsMap);
        }
        if (notificareInboxItem.getExtra() != null) {
            WritableMap extraMap = Arguments.createMap();
            for (HashMap.Entry<String, String> prop : notificareInboxItem.getExtra().entrySet()) {
                extraMap.putString(prop.getKey(), prop.getValue());
            }
            inboxItemMap.putMap("extra", extraMap);
        }
        inboxItemMap.putString("time", ISODateFormatter.format(notificareInboxItem.getTimestamp()));
        inboxItemMap.putBoolean("opened", notificareInboxItem.getStatus());
        return inboxItemMap;
    }

    public static WritableMap mapBeacon(NotificareBeacon beacon) {
        WritableMap map = Arguments.createMap();
        map.putString("beaconId", beacon.getBeaconId());
        map.putString("beaconName", beacon.getName());
        map.putString("beaconRegion", beacon.getRegionId());
        map.putString("beaconUUID", Notificare.shared().getApplicationInfo().getRegionConfig().getProximityUUID());
        map.putInt("beaconMajor", beacon.getMajor());
        map.putInt("beaconMinor", beacon.getMinor());
        map.putBoolean("beaconTriggers", beacon.getTriggers());
        return map;
    }

    public static WritableMap mapRegion(NotificareRegion region) {
        WritableMap map = Arguments.createMap();
        map.putString("regionId", region.getRegionId());
        map.putString("regionName", region.getName());
        map.putInt("regionMajor", region.getMajor());
        if (region.getGeometry() != null) {
            map.putMap("regionGeometry", mapPoint(region.getGeometry()));
        }
        if (region.getAdvancedGeometry() != null) {
            map.putMap("regionAdvancedGeometry", mapPolygon(region.getAdvancedGeometry()));
        }
        map.putDouble("regionDistance", region.getDistance());
        map.putString("regionTimezone", region.getTimezone());
        return map;
    }

    public static WritableMap mapPoint(NotificarePoint point) {
        WritableMap map = Arguments.createMap();
        map.putString("type", point.getType());
        WritableArray coordinates = Arguments.createArray();
        coordinates.pushDouble(point.getLongitude());
        coordinates.pushDouble(point.getLatitude());
        map.putArray("coordinates", coordinates);
        return map;
    }

    public static WritableMap mapPolygon(NotificarePolygon polygon) {
        WritableMap map = Arguments.createMap();
        map.putString("type", polygon.getType());
        WritableArray ring = Arguments.createArray();
        WritableArray coordinatesList = Arguments.createArray();
        for (NotificareCoordinates coordinates : polygon.getCoordinates()) {
            WritableArray coordinatesPair = Arguments.createArray();
            coordinatesPair.pushDouble(coordinates.getLongitude());
            coordinatesPair.pushDouble(coordinates.getLatitude());
            coordinatesList.pushArray(coordinatesPair);
        }
        ring.pushArray(coordinatesList);
        map.putArray("coordinates", ring);
        return map;
    }

    public static WritableMap mapPass(NotificarePass pass) {
        WritableMap map = Arguments.createMap();
        map.putString("passbook", pass.getPassbook());
        map.putString("serial", pass.getSerial());
        if (pass.getRedeem() == NotificarePass.Redeem.ALWAYS) {
            map.putString("redeem", "always");
        } else if (pass.getRedeem() == NotificarePass.Redeem.LIMIT) {
            map.putString("redeem", "limit");
        } else if (pass.getRedeem() == NotificarePass.Redeem.ONCE) {
            map.putString("redeem", "once");
        }
        map.putString("token", pass.getToken());
        if (pass.getData() != null) {
            map.putMap("data", mapJSON(pass.getData()));
        }
        map.putString("date", ISODateFormatter.format(pass.getDate()));
        map.putInt("limit", pass.getLimit());
        WritableArray redeemHistory = Arguments.createArray();
        for (NotificarePassRedemption redemption : pass.getRedeemHistory()) {
            WritableMap redemptionMap = Arguments.createMap();
            redemptionMap.putString("comments", redemption.getComments());
            redemptionMap.putString("date", ISODateFormatter.format(redemption.getDate()));
            redeemHistory.pushMap(redemptionMap);
        }
        map.putArray("redeemHistory", redeemHistory);
        return map;
    }

    public static WritableArray mapProducts(List<NotificareProduct> products) {
        WritableArray productList = Arguments.createArray();
        for (NotificareProduct product : products){
            productList.pushMap(mapProduct(product));
        }
        return productList;
    }

    public static WritableMap mapProduct(NotificareProduct product) {
        WritableMap productItemMap = Arguments.createMap();
        productItemMap.putString("productType", product.getType());
        productItemMap.putString("productIdentifier", product.getIdentifier());
        productItemMap.putString("productName", product.getName());
        productItemMap.putString("productDescription", product.getSkuDetails().getDescription());
        productItemMap.putString("productPrice", product.getSkuDetails().getPrice());
        productItemMap.putString("productCurrency", product.getSkuDetails().getPriceCurrencyCode());
        productItemMap.putString("productDate", ISODateFormatter.format(product.getDate()));
        productItemMap.putBoolean("productActive", true);
        return productItemMap;
    }

    public static WritableMap mapUser(NotificareUser user) {
        WritableMap userMap = Arguments.createMap();
        userMap.putString("userID", user.getUserId());
        userMap.putString("userName", user.getUserName());
        WritableArray segments = Arguments.createArray();
        if (user.getSegments() != null) {
            for (String segmentId : user.getSegments()) {
                segments.pushString(segmentId);
            }
        }
        userMap.putArray("segments", segments);
        return userMap;
    }

    public static WritableArray mapUserSegments(List<NotificareUserSegment> userSegments) {
        WritableArray userSegmentsArray = Arguments.createArray();
        for (NotificareUserSegment userSegment : userSegments) {
            userSegmentsArray.pushMap(mapUserSegment(userSegment));
        }
        return userSegmentsArray;
    }

    public static WritableMap mapUserPreference(NotificareUserPreference userPreference) {
        WritableMap userPreferenceMap = Arguments.createMap();
        userPreferenceMap.putString("preferenceId", userPreference.getId());
        userPreferenceMap.putString("preferenceLabel", userPreference.getLabel());
        userPreferenceMap.putString("preferenceType", userPreference.getPreferenceType());
        WritableArray options = Arguments.createArray();
        for (NotificareUserPreferenceOption option : userPreference.getPreferenceOptions()) {
            WritableMap optionMap = Arguments.createMap();
            optionMap.putString("segmentId", option.getUserSegmentId());
            optionMap.putString("segmentLabel", option.getLabel());
            optionMap.putBoolean("selected", option.isSelected());
            options.pushMap(optionMap);
        }
        userPreferenceMap.putArray("preferenceOptions", options);
        return userPreferenceMap;
    }

    public static NotificareUserPreference createUserPreference(ReadableMap userPreferenceMap) {
        try {
            JSONObject json = new JSONObject();
            json.put("_id", userPreferenceMap.getString("preferenceId"));
            json.put("label", userPreferenceMap.getString("preferenceLabel"));
            json.put("preferenceType", userPreferenceMap.getString("preferenceType"));
            return new NotificareUserPreference(json);
        } catch (JSONException e) {
            return null;
        }
    }


    public static WritableMap mapUserSegment(NotificareUserSegment userSegment) {
        WritableMap userSegmentMap = Arguments.createMap();
        userSegmentMap.putString("segmentId", userSegment.getId());
        userSegmentMap.putString("segmentLabel", userSegment.getName());
        return userSegmentMap;
    }

    public static NotificareUserSegment createUserSegment(ReadableMap userSegmentMap) {
        try {
            JSONObject json = new JSONObject();
            json.put("_id", userSegmentMap.getString("segmentId"));
            json.put("name", userSegmentMap.getString("segmentLabel"));
            return new NotificareUserSegment(json);
        } catch (JSONException e) {
            return null;
        }
    }

    public static WritableMap mapScannable(NotificareScannable scannable) {
        WritableMap scannableMap = Arguments.createMap();
        scannableMap.putString("scannableId", scannable.getScannableId());
        scannableMap.putString("name", scannable.getName());
        scannableMap.putString("type", scannable.getType());
        scannableMap.putString("tag", scannable.getTag());
        scannableMap.putMap("data", mapJSON(scannable.getData()));
        scannableMap.putMap("notification", mapNotification(scannable.getNotification()));
        return scannableMap;
    }

}
