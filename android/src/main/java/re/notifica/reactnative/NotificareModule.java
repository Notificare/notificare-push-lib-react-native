package re.notifica.reactnative;

import android.os.Bundle;
import android.os.Parcel;
import android.support.v4.content.ContextCompat;
import android.util.Log;

import com.facebook.react.bridge.NativeModule;
import com.facebook.react.bridge.ReactApplicationContext;
import com.facebook.react.bridge.ReactContext;
import com.facebook.react.bridge.ReactContextBaseJavaModule;
import com.facebook.react.bridge.ReactMethod;
import com.facebook.react.bridge.Callback;
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

import javax.annotation.Nullable;

import re.notifica.Notificare;
import re.notifica.NotificareCallback;
import re.notifica.NotificareError;
import re.notifica.model.NotificareAsset;
import re.notifica.model.NotificareContent;
import re.notifica.model.NotificareNotification;

public class NotificareModule extends ReactContextBaseJavaModule  {

    public NotificareModule(ReactApplicationContext reactContext) {
        super(reactContext);
    }

    @Override
    public String getName() {
        return "NotificareReactNativeAndroid";
    }

    @ReactMethod
    public void launch() {
        Notificare.shared().launch(getReactApplicationContext());
        Notificare.shared().setDebugLogging(BuildConfig.DEBUG);
        Notificare.shared().setIntentReceiver(NotificareReceiver.class);
    }

    @ReactMethod
    public void setSmallIcon(String iconName) {
        int iconId = getImageResourceId(iconName);
        Notificare.shared().setSmallIcon(iconId);
    }

    @ReactMethod
    public void setAllowJavaScript(Boolean allowJS) {
        Notificare.shared().setAutoCancel(allowJS);
    }

    @ReactMethod
    public void setAutoCancel(Boolean autoCancel) {
        Notificare.shared().setAutoCancel(autoCancel);
    }

    @ReactMethod
    public void setDefaultLights(String color, int on, int off) {
        Notificare.shared().setDefaultLightsColor(color);
        Notificare.shared().setDefaultLightsOn(on);
        Notificare.shared().setDefaultLightsOff(off);
    }

    @ReactMethod
    public void setNotificationAccentColor(String color) {
        Notificare.shared().setNotificationAccentColor(ContextCompat.getColor(getReactApplicationContext(), getColorResourceId(color)));
    }

    @ReactMethod
    public void setCrashLogs(Boolean crashLogs) {
        Notificare.shared().setCrashLogs(crashLogs);
    }

    @ReactMethod
    public void enableNotifications() {
        Notificare.shared().enableNotifications();
    }

    @ReactMethod
    public void disableNotifications() {
        Notificare.shared().disableNotifications();
    }

    @ReactMethod
    public void enableLocationUpdates() {
        Notificare.shared().enableLocationUpdates();
    }

    @ReactMethod
    public void disableLocationUpdates() {
        Notificare.shared().disableLocationUpdates();
    }

    @ReactMethod
    public void enableBeacons() {
        Notificare.shared().enableBeacons();
    }

    @ReactMethod
    public void disableBeacons() {
        Notificare.shared().disableBeacons();
    }

    @ReactMethod
    public void enableBilling() {
        Notificare.shared().enableBilling();
    }

    @ReactMethod
    public void disableBilling() {
        Notificare.shared().disableBilling();
    }

    @ReactMethod
    public void isNotificationsEnabled(final Callback callback) {

        callback.invoke(Notificare.shared().isNotificationsEnabled());

    }

    @ReactMethod
    public void isLocationUpdatesEnabled(final Callback callback) {

        callback.invoke(Notificare.shared().isLocationUpdatesEnabled());

    }

    @ReactMethod
    public void registerDevice( String deviceId, String userId, String userName, final Callback callback ) {

        Notificare.shared().registerDevice(deviceId, userId, userName, new NotificareCallback<String>() {

            @Override
            public void onSuccess(String result) {
                callback.invoke(null, result);
            }

            @Override
            public void onError(NotificareError error) {

                callback.invoke(error.getMessage(), null);

            }

        });

    }

    @ReactMethod
    public void openNotification(ReadableMap notification) {

        /*
        ReadableMap theNotification = notification.getMap("notification");
        try {
            JSONObject jsonObject = new JSONObject();
            jsonObject.put("_id", theNotification.getString("id"));
            jsonObject.put("message", theNotification.getString("message"));
            jsonObject.put("type", theNotification.getString("type"));
            jsonObject.put("time", theNotification.getString("time"));

            JSONArray theActions = new JSONArray();

            for (int i = 0; i < theNotification.getArray("actions").size(); i++) {
                ReadableMap theAction = theNotification.getArray("actions").getMap(i);
                theActions.put()
            }


            jsonObject.put("actions", theActions);
            Notificare.shared().fetchNotification("", new NotificareCallback<NotificareNotification>() {
                @Override
                public void onSuccess(NotificareNotification notificareNotification) {
                    Bundle m

                    Notificare.shared().openNotification(getCurrentActivity(), message);

                }

                @Override
                public void onError(NotificareError notificareError) {

                }
            });
        } catch (JSONException e) {
            Log.e("Notificare", "Could not evaluate notification object");
        }
        */
        ReadableMap theNotification = notification.getMap("notification");
        Notificare.shared().fetchNotification(theNotification.getString("id"), new NotificareCallback<NotificareNotification>() {
            @Override
            public void onSuccess(NotificareNotification notificareNotification) {

                Notificare.shared().openNotification(getCurrentActivity(), notificareNotification);

            }

            @Override
            public void onError(NotificareError notificareError) {

            }
        });
    }

    @ReactMethod
    public void fetchTags( final Callback callback ) {

        Notificare.shared().fetchDeviceTags(new NotificareCallback<List<String>>() {

            @Override
            public void onError(NotificareError arg0) {

                callback.invoke(arg0.getMessage(), null);

            }

            @Override
            public void onSuccess(List<String> arg0) {

                WritableArray tags = Arguments.createArray();
                WritableMap a = Arguments.createMap();

                for (String tag : arg0) {
                    tags.pushString(tag);
                }

                a.putArray("tags", tags);
                callback.invoke(null, a);

            }

        });

    }

    @ReactMethod
    public void addTags(ReadableArray tags, final Callback callback ) {

        List<String> theTags = new ArrayList<String>(tags.size());
        for (int i = 0; i < tags.size(); i++) {
            theTags.add(tags.getString(i));
        }

        Notificare.shared().addDeviceTags(theTags, new NotificareCallback<Boolean>() {
            @Override
            public void onSuccess(Boolean aBoolean) {
                callback.invoke(null, "tags added successfully");
            }

            @Override
            public void onError(NotificareError notificareError) {
                callback.invoke(notificareError.getMessage(), null);
            }
        });

    }

    @ReactMethod
    public void removeTag(String tag, final Callback callback ) {

        Notificare.shared().removeDeviceTag(tag, new NotificareCallback<Boolean>() {
            @Override
            public void onSuccess(Boolean aBoolean) {
                callback.invoke(null, "tag removed successfully");
            }

            @Override
            public void onError(NotificareError notificareError) {
                callback.invoke(notificareError.getMessage(), null);
            }
        });

    }

    @ReactMethod
    public void clearTags(final Callback callback ) {

        Notificare.shared().clearDeviceTags(new NotificareCallback<Boolean>() {
            @Override
            public void onSuccess(Boolean aBoolean) {
                callback.invoke(null, "tags added successfully");
            }

            @Override
            public void onError(NotificareError notificareError) {
                callback.invoke(notificareError.getMessage(), null);
            }
        });

    }


    @ReactMethod
    public void fetchAssets(String query, final Callback callback ){

        Notificare.shared().fetchAssets(query, new NotificareCallback<List<NotificareAsset>>() {
            @Override
            public void onSuccess(List<NotificareAsset> notificareAssets) {

                WritableArray assets = Arguments.createArray();

                for (NotificareAsset asset : notificareAssets) {

                    WritableMap theAsset = Arguments.createMap();

                    theAsset.putString("title", asset.getTitle());
                    theAsset.putString("description", asset.getDescription());
                    theAsset.putString("url", asset.getUrl().toString());

                    WritableMap theMeta = Arguments.createMap();
                    theMeta.putString("originalFileName", asset.getOriginalFileName());
                    theMeta.putString("key", asset.getKey());
                    theMeta.putString("contentType", asset.getContentType());
                    theMeta.putInt("contentLength", asset.getContentLength());
                    theAsset.putMap("metaData", theMeta);

                    WritableMap theButton = Arguments.createMap();
                    theButton.putString("label", asset.getButtonLabel());
                    theButton.putString("action", asset.getButtonAction());
                    theAsset.putMap("button", theButton);

                    assets.pushMap(theAsset);
                }

                callback.invoke(null, assets);

            }

            @Override
            public void onError(NotificareError notificareError) {
                callback.invoke(notificareError.getMessage(), null);
            }

        });
    }


    @ReactMethod
    public void logCustomEvent(String name, @Nullable ReadableMap data, final Callback callback ) {

        Notificare.shared().getEventLogger().logCustomEvent(name, toHashMap(data));

    }

    private int getImageResourceId(String imageName) {
        if (imageName == null || imageName.length() <= 0) {
            return -1;
        }
        int imageId = getImageResourceId(imageName, "drawable");
        if (imageId == 0) {
            imageId = getImageResourceId(imageName, "mipmap");
        }
        return imageId;
    }

    private int getImageResourceId(String imageName, String imageResourceType) {
        return getReactApplicationContext().getResources().getIdentifier(
                imageName,
                imageResourceType,
                getReactApplicationContext().getPackageName());
    }

    private int getColorResourceId(String colorResource) {
        if (colorResource == null || colorResource.length() <= 0) {
            return -1;
        }
        int imageId = getImageResourceId(colorResource, "color");
        if (imageId == 0) {
            return -1;
        }

        return getReactApplicationContext().getResources().getIdentifier(
                colorResource,
                "color",
                getReactApplicationContext().getPackageName());
    }


    public static HashMap<String, Object> toHashMap(@Nullable ReadableMap data) {

        if (data == null) {
            return null;
        }

        HashMap<String, Object> theData = new HashMap<String, Object>();
        ReadableMapKeySetIterator iterator = data.keySetIterator();
        if (iterator.hasNextKey()) {
            while (iterator.hasNextKey()) {
                String key = iterator.nextKey();
                ReadableType readableType = data.getType(key);
                switch (readableType) {
                    case Null:
                        theData.put(key, null);
                        break;
                    case Boolean:
                        theData.put(key, data.getBoolean(key));
                        break;
                    case Number:
                        theData.put(key, data.getDouble(key));
                        break;
                    case String:
                        theData.put(key, data.getString(key));
                        break;
                    case Map:
                        theData.put(key, toHashMap(data.getMap(key)));
                        break;
                    default:
                        break;
                }
            }
        }

        return theData;
    }
}