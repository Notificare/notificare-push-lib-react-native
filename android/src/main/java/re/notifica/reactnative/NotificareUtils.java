package re.notifica.reactnative;

import android.widget.ArrayAdapter;
import android.widget.ListAdapter;

import com.facebook.react.bridge.Arguments;
import com.facebook.react.bridge.ReadableArray;
import com.facebook.react.bridge.ReadableMap;
import com.facebook.react.bridge.ReadableMapKeySetIterator;
import com.facebook.react.bridge.ReadableType;
import com.facebook.react.bridge.WritableArray;
import com.facebook.react.bridge.WritableMap;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import javax.annotation.Nullable;

import re.notifica.model.NotificareAction;
import re.notifica.model.NotificareApplicationInfo;
import re.notifica.model.NotificareAsset;
import re.notifica.model.NotificareAttachment;
import re.notifica.model.NotificareContent;
import re.notifica.model.NotificareInboxItem;
import re.notifica.model.NotificareNotification;
import re.notifica.model.NotificareProduct;
import re.notifica.model.NotificareTimeOfDayRange;
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
                Log.e(TAG,e.getMessage());
                return null;
            }
        }
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

    public static WritableArray mapProducts(List<NotificareProduct> products) {
        WritableArray productList = Arguments.createArray();

        for (NotificareProduct product : products){

            WritableMap productItemMap = Arguments.createMap();
            productItemMap.putString("type", product.getType());
            productItemMap.putString("identifier", product.getIdentifier());
            productItemMap.putString("name", product.getName());
            productItemMap.putString("date", ISODateFormatter.format(product.getDate()));

            WritableMap skuDetails = Arguments.createMap();
            skuDetails.putString("type", product.getSkuDetails().getType());
            skuDetails.putString("description", product.getSkuDetails().getDescription());
            skuDetails.putString("price", product.getSkuDetails().getPrice());
            skuDetails.putString("currencyCode", product.getSkuDetails().getPriceCurrencyCode());
            skuDetails.putString("productId", product.getSkuDetails().getProductId());
            skuDetails.putString("title", product.getSkuDetails().getTitle());
            skuDetails.putDouble("priceAmount", product.getSkuDetails().getPriceAmount());
            skuDetails.putDouble("priceAmountMicros", product.getSkuDetails().getPriceAmountMicros());
            productItemMap.putMap("skuDetails", skuDetails);

            productList.pushMap(productItemMap);
        }


        return productList;
    }

}
