package re.notifica.reactnative;

import android.app.Activity;
import android.content.Intent;
import android.support.v4.content.ContextCompat;
import android.util.Log;

import com.facebook.react.bridge.ActivityEventListener;
import com.facebook.react.bridge.Arguments;
import com.facebook.react.bridge.Callback;
import com.facebook.react.bridge.LifecycleEventListener;
import com.facebook.react.bridge.ReactApplicationContext;
import com.facebook.react.bridge.ReactContextBaseJavaModule;
import com.facebook.react.bridge.ReactMethod;
import com.facebook.react.bridge.ReadableArray;
import com.facebook.react.bridge.ReadableMap;
import com.facebook.react.bridge.WritableArray;
import com.facebook.react.bridge.WritableMap;

import org.json.JSONException;
import org.json.JSONObject;

import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Date;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import javax.annotation.Nullable;

import re.notifica.Notificare;
import re.notifica.NotificareCallback;
import re.notifica.NotificareError;
import re.notifica.model.NotificareAction;
import re.notifica.model.NotificareApplicationInfo;
import re.notifica.model.NotificareAsset;
import re.notifica.model.NotificareContent;
import re.notifica.model.NotificareInboxItem;
import re.notifica.model.NotificareNotification;
import re.notifica.model.NotificareTimeOfDay;
import re.notifica.model.NotificareTimeOfDayRange;
import re.notifica.model.NotificareUserData;
import re.notifica.model.NotificareUserDataField;

public class NotificareModule extends ReactContextBaseJavaModule implements ActivityEventListener, LifecycleEventListener, Notificare.OnNotificareReadyListener, Notificare.OnServiceErrorListener, Notificare.OnNotificationReceivedListener {

    private static final String TAG = NotificareModule.class.getSimpleName();

    private Map<String,NotificareNotification> notificationCache = new HashMap<>();
    private Boolean launched = false;
    private Boolean intentHandled = false;


    public NotificareModule(ReactApplicationContext reactContext) {
        super(reactContext);
        getReactApplicationContext().addActivityEventListener(this);
        getReactApplicationContext().addLifecycleEventListener(this);
    }

    @Override
    public String getName() {
        return "NotificareReactNativeAndroid";
    }

    // Event methods

    /**
     * Send a notification opened event
     * @param notificationMap
     */
    private void sendNotification(WritableMap notificationMap) {
        if (notificationMap != null) {
            WritableMap payload = Arguments.createMap();
            payload.putMap("notification", notificationMap);
            NotificareEventEmitter.getInstance().sendEvent("onNotificationOpened", payload);
        }
    }

    // React methods


    @ReactMethod
    public void launch() {
//        Notificare.shared().launch(getReactApplicationContext());
//        Notificare.shared().setIntentReceiver(NotificareReceiver.class);
//        Notificare.shared().setAllowJavaScript(true);
        if (!launched) {
            Notificare.shared().addNotificareReadyListener(this);
            launched = true;
        }
    }

    @ReactMethod
    public void setSmallIcon(String iconName) {
        int iconId = getDrawableResource(iconName);
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
        Notificare.shared().setNotificationAccentColor(ContextCompat.getColor(getReactApplicationContext(), getColorResource(color)));
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
//        if (!Notificare.shared().hasLocationPermissionGranted()) {
//            if (Notificare.shared().didRequestLocationPermission()) {
//                if (Notificare.shared().shouldShowRequestPermissionRationale(getCurrentActivity())) {
//                    // Here we should show a dialog explaining location updates
//                    builder.setMessage(R.string.alert_location_permission_rationale)
//                            .setTitle(R.string.app_name)
//                            .setCancelable(true)
//                            .setPositiveButton(R.string.button_location_permission_rationale_ok, new DialogInterface.OnClickListener() {
//                                public void onClick(DialogInterface dialog, int id) {
//                                    Notificare.shared().requestLocationPermission(MainActivity.this, LOCATION_PERMISSION_REQUEST_CODE);
//                                }
//                            })
//                            .create()
//                            .show();
//                }
//            } else {
//                Notificare.shared().requestLocationPermission(this, LOCATION_PERMISSION_REQUEST_CODE);
//            }
//        }
//
//
//
//        if (!Notificare.shared().hasLocationPermissionGranted()) {
//            Log.i(TAG, "permission not granted");
//            getCurrentActivity().requestPermissions(this, LOCATION_PERMISSION_REQUEST_CODE, new String[]{android.Manifest.permission.ACCESS_FINE_LOCATION});
//        } else {
//            Notificare.shared().enableLocationUpdates();
//        }
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
        ReadableMap notificationMap = notification.getMap("notification");
        String notificationId = notificationMap.getString("id");
        if (notificationId != null && !notificationId.isEmpty()) {
            if (notificationCache.containsKey(notificationId)) {
                Notificare.shared().openNotification(getCurrentActivity(), notificationCache.get(notificationId));
                notificationCache.remove(notificationCache.get(notificationId));
            } else {
                Notificare.shared().fetchNotification(notificationId, new NotificareCallback<NotificareNotification>() {
                    @Override
                    public void onSuccess(NotificareNotification notificareNotification) {
                        Notificare.shared().openNotification(getCurrentActivity(), notificareNotification);
                    }

                    @Override
                    public void onError(NotificareError notificareError) {

                    }
                });
            }
        }
    }

    @ReactMethod
    public void fetchInboxItems(@Nullable String date, @Nullable int skip, @Nullable int limit, final Callback callback ) {

        SimpleDateFormat format = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss");
        Date theDate = null;
        if (date != null) {
            try {
                theDate = format.parse(date);
            } catch (ParseException e) {
                e.printStackTrace();
            }
        }

        Notificare.shared().fetchInboxItems(theDate, skip, limit, new NotificareCallback<List<NotificareInboxItem>>() {
            @Override
            public void onSuccess(List<NotificareInboxItem> notificareInboxItems) {

                WritableMap payload = Arguments.createMap();
                WritableArray inboxItems = Arguments.createArray();

                for (NotificareInboxItem item : notificareInboxItems){
                    WritableMap inboxItem = Arguments.createMap();
                    inboxItem.putString("inboxId", item.getItemId());
                    inboxItem.putString("notification", item.getNotification().getNotificationId());
                    inboxItem.putString("message", item.getNotification().getMessage());
                    inboxItem.putBoolean("opened", item.getStatus());
                    inboxItem.putString("time", item.getTimestamp().toString());
                    inboxItems.pushMap(inboxItem);
                }

                payload.putArray("inbox", inboxItems);
                callback.invoke(null, payload);

            }

            @Override
            public void onError(NotificareError notificareError) {
                callback.invoke(notificareError.getMessage(), null);
            }
        });
    }

    @ReactMethod
    public void openInboxItem(ReadableMap inboxItem, final Callback callback ) {

        Notificare.shared().fetchNotification(inboxItem.getString("notification"), new NotificareCallback<NotificareNotification>() {
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
    public void removeInboxItem(String inboxItemId, final Callback callback ) {

        Notificare.shared().deleteInboxItem(inboxItemId, new NotificareCallback<Boolean>() {
            @Override
            public void onSuccess(Boolean aBoolean) {
                callback.invoke(null, "Inbox item removed successfully");
            }

            @Override
            public void onError(NotificareError notificareError) {
                callback.invoke(notificareError.getMessage(), null);
            }
        });
    }

    @ReactMethod
    public void clearInbox(final Callback callback ) {

        Notificare.shared().clearInbox(new NotificareCallback<Boolean>() {
            @Override
            public void onSuccess(Boolean aBoolean) {
                callback.invoke(null, "Inbox cleared successfully");
            }

            @Override
            public void onError(NotificareError notificareError) {
                callback.invoke(notificareError.getMessage(), null);
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
                WritableMap payload = Arguments.createMap();

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

                payload.putArray("assets", assets);
                callback.invoke(null, payload);

            }

            @Override
            public void onError(NotificareError notificareError) {
                callback.invoke(notificareError.getMessage(), null);
            }

        });
    }

    @ReactMethod
    public void fetchUserData(final Callback callback ){

        Notificare.shared().fetchUserData(new NotificareCallback<NotificareUserData>() {
            @Override
            public void onSuccess(NotificareUserData notificareUserData) {
                WritableMap payload = Arguments.createMap();
                WritableArray userDataFields = Arguments.createArray();
                for (HashMap.Entry<String, NotificareUserDataField> fields : Notificare.shared().getApplicationInfo().getUserDataFields().entrySet()){
                    WritableMap c = Arguments.createMap();
                    c.putString(fields.getKey(), notificareUserData.getValue(fields.getKey()));
                    userDataFields.pushMap(c);
                }

                payload.putArray("userData", userDataFields);

                callback.invoke(null, payload);
            }

            @Override
            public void onError(NotificareError notificareError) {
                callback.invoke(notificareError.getMessage(), null);
            }
        });
    }

    @ReactMethod
    public void updateUserData(ReadableMap userData, final Callback callback) {

        Map<String, Object> fields = NotificareUtils.createMap(userData);

        userData.keySetIterator();
        NotificareUserData data = new NotificareUserData();
        for (String key : fields.keySet()) {
            data.setValue(key, fields.get(key).toString());
        }

        Notificare.shared().updateUserData(data, new NotificareCallback<Boolean>() {
            @Override
            public void onSuccess(Boolean aBoolean) {
                callback.invoke(null, "User Data Fields updated successfully");
            }

            @Override
            public void onError(NotificareError notificareError) {
                callback.invoke(notificareError.getMessage(), null);
            }
        });
    }


    @ReactMethod
    public void fetchDoNotDisturb(final Callback callback) {

        Notificare.shared().fetchDoNotDisturb(new NotificareCallback<NotificareTimeOfDayRange>() {
            @Override
            public void onSuccess(NotificareTimeOfDayRange notificareTimeOfDayRange) {
                WritableMap payload = Arguments.createMap();
                WritableMap dnd = Arguments.createMap();
                dnd.putString("start", notificareTimeOfDayRange.getStart().toString());
                dnd.putString("end", notificareTimeOfDayRange.getEnd().toString());
                payload.putMap("dnd", dnd);
                callback.invoke(null, payload);
            }

            @Override
            public void onError(NotificareError notificareError) {
                callback.invoke(notificareError.getMessage(), null);
            }
        });
    }

    @ReactMethod
    public void updateDoNotDisturb(String start, String end, final Callback callback) {

        String[] s = start.split(":");
        String[] e = end.split(":");

        NotificareTimeOfDayRange range = new NotificareTimeOfDayRange(
                new NotificareTimeOfDay(Integer.parseInt(s[0]),Integer.parseInt(s[1])),
                new NotificareTimeOfDay(Integer.parseInt(e[0]),Integer.parseInt(e[1])));

        Notificare.shared().updateDoNotDisturb(range, new NotificareCallback<Boolean>() {
            @Override
            public void onSuccess(Boolean aBoolean) {
                callback.invoke(null, "Do Not Disturb updated successfully");
            }

            @Override
            public void onError(NotificareError notificareError) {
                callback.invoke(notificareError.getMessage(), null);
            }
        });
    }

    @ReactMethod
    public void clearDoNotDisturb(final Callback callback) {

        Notificare.shared().clearDoNotDisturb(new NotificareCallback<Boolean>() {
            @Override
            public void onSuccess(Boolean aBoolean) {
                callback.invoke(null, "Dot Not Disturb cleared");
            }

            @Override
            public void onError(NotificareError notificareError) {
                callback.invoke(notificareError.getMessage(), null);
            }
        });
    }

    @ReactMethod
    public void logCustomEvent(String name, @Nullable ReadableMap data, final Callback callback) {
        Notificare.shared().getEventLogger().logCustomEvent(name, NotificareUtils.createMap(data));
    }

    // ActivityEventListener methods

    /**
     * Called when host (activity/service) receives an {@link Activity#onActivityResult} call.
     *
     * @param activity
     * @param requestCode
     * @param resultCode
     * @param data
     */
    @Override
    public void onActivityResult(Activity activity, int requestCode, int resultCode, Intent data) {
        Notificare.shared().handleServiceErrorResolution(requestCode, resultCode, data);
    }

    /**
     * Called when a new intent is passed to the activity
     *
     * @param intent
     */
    @Override
    public void onNewIntent(Intent intent) {
        Log.i(TAG, "new intent: " + intent);
        // Check for launch with notification or tokens
        sendNotification(parseNotificationIntent(intent));
//        sendValidateUserToken(Notificare.shared().parseValidateUserIntent(intent));
//        sendResetPasswordToken(Notificare.shared().parseResetPasswordIntent(intent));
    }

    // LifecycleEventListener methods

    /**
     * Called either when the host activity receives a resume event (e.g. {@link Activity#onResume} or
     * if the native module that implements this is initialized while the host activity is already
     * resumed. Always called for the most current activity.
     */
    @Override
    public void onHostResume() {
        Log.i(TAG, "host resume");
        if (!intentHandled) {
            sendNotification(parseNotificationIntent(getCurrentActivity().getIntent()));
            intentHandled = true;
        }
        Notificare.shared().addServiceErrorListener(this);
        Notificare.shared().setForeground(true);
        Notificare.shared().addNotificationReceivedListener(this);
        Notificare.shared().getEventLogger().logStartSession();
    }

    /**
     * Called when host activity receives pause event (e.g. {@link Activity#onPause}. Always called
     * for the most current activity.
     */
    @Override
    public void onHostPause() {
        Log.i(TAG, "host pause");
        Notificare.shared().removeServiceErrorListener(this);
        Notificare.shared().removeNotificationReceivedListener(this);
        Notificare.shared().setForeground(false);
        Notificare.shared().getEventLogger().logEndSession();
    }

    /**
     * Called when host activity receives destroy event (e.g. {@link Activity#onDestroy}. Only called
     * for the last React activity to be destroyed.
     */
    @Override
    public void onHostDestroy() {
        Log.i(TAG, "host destroy");
        Notificare.shared().removeServiceErrorListener(this);
        Notificare.shared().removeNotificationReceivedListener(this);
        Notificare.shared().setForeground(false);
        Notificare.shared().getEventLogger().logEndSession();
    }

    // OnNotificareReadyListener

    @Override
    public void onNotificareReady(NotificareApplicationInfo notificareApplicationInfo) {
        Log.i(TAG, "on ready in module");
        WritableMap payload = Arguments.createMap();
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

        payload.putMap("application", infoMap);
        NotificareEventEmitter.getInstance().sendEvent("onReady", payload);
    }

    // OnServiceErrorListener

    @Override
    public void onServiceError(int errorCode, int requestCode) {
        if (Notificare.isUserRecoverableError(errorCode).booleanValue()) {
            Notificare.getErrorDialog(errorCode, getCurrentActivity(), requestCode).show();
        }
    }

    // OnNotificationReceivedListener

    @Override
    public void onNotificationReceived(NotificareNotification notificareNotification) {
        // TODO: serialize notification to event arguments
        //NotificareEventEmitter.getInstance().sendEvent("onNotificationReceived", notificareNotification);
    }

    // Utility methods

    /**
     * Parse notification from launch intent
     * @param intent
     * @return
     */
    protected WritableMap parseNotificationIntent(Intent intent) {
        NotificareNotification notification = intent.getParcelableExtra(Notificare.INTENT_EXTRA_NOTIFICATION);
        if (notification != null) {
            WritableMap notificationMap = Arguments.createMap();
            notificationMap.putString("id", notification.getNotificationId());
            if (intent.hasExtra(Notificare.INTENT_EXTRA_INBOX_ITEM_ID)) {
                notificationMap.putString("inboxItemId", intent.getStringExtra(Notificare.INTENT_EXTRA_INBOX_ITEM_ID));
            }
            notificationMap.putString("message", notification.getMessage());
            notificationMap.putString("title", notification.getTitle());
            notificationMap.putString("subtitle", notification.getSubtitle());
            notificationMap.putString("type", notification.getType());
            notificationMap.putString("time", notification.getTime().toString());


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
        return null;
    }


    /**
     * Get a resource by name and type
     * @param resourceName
     * @param resourceType
     * @return
     */
    private int getResource(String resourceName, String resourceType) {
        return getReactApplicationContext().getResources().getIdentifier(
                resourceName,
                resourceType,
                getReactApplicationContext().getPackageName());
    }

    /**
     * Get a drawable resource by name
     * @param imageName
     * @return
     */
    private int getDrawableResource(String imageName) {
        if (imageName == null || imageName.isEmpty()) {
            return 0;
        }
        return getResource(imageName, "drawable");
    }

    /**
     * Get a color resource by name
     * @param colorName
     * @return
     */
    private int getColorResource(String colorName) {
        if (colorName == null || colorName.isEmpty()) {
            return 0;
        }
        return getResource(colorName, "color");
    }

    private Boolean isActive() {
        return getReactApplicationContext().hasActiveCatalystInstance() && getReactApplicationContext().hasCurrentActivity();
    }

}