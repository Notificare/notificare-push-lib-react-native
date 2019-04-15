package re.notifica.reactnative;

import android.app.Activity;
import android.content.Intent;

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

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import javax.annotation.Nullable;

import re.notifica.Notificare;
import re.notifica.NotificareCallback;
import re.notifica.NotificareError;
import re.notifica.billing.BillingManager;
import re.notifica.billing.BillingResult;
import re.notifica.billing.Purchase;
import re.notifica.model.NotificareApplicationInfo;
import re.notifica.model.NotificareAsset;
import re.notifica.model.NotificareInboxItem;
import re.notifica.model.NotificareNotification;
import re.notifica.model.NotificareProduct;
import re.notifica.model.NotificareTimeOfDay;
import re.notifica.model.NotificareTimeOfDayRange;
import re.notifica.model.NotificareUserData;
import re.notifica.model.NotificareUserDataField;
import re.notifica.util.Log;

class NotificareModule extends ReactContextBaseJavaModule implements ActivityEventListener, LifecycleEventListener, Notificare.OnNotificareReadyListener, Notificare.OnServiceErrorListener, Notificare.OnNotificationReceivedListener, Notificare.OnBillingReadyListener, BillingManager.OnRefreshFinishedListener, BillingManager.OnPurchaseFinishedListener {

    private static final String TAG = NotificareModule.class.getSimpleName();
    private static final int DEFAULT_LIST_SIZE = 25;

    private Boolean mounted = false;
    private Boolean isBillingReady = false;


    NotificareModule(ReactApplicationContext reactContext) {
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
     * Send an event to the JS context
     * @param eventName
     * @param payload
     */
    public void sendEvent(String eventName, WritableMap payload) {
        sendEvent(eventName, payload, false);
    }

    /**
     * Send an event to the JS context
     * @param eventName
     * @param payload
     * @param queue
     */
    private void sendEvent(String eventName, WritableMap payload, Boolean queue) {
        NotificareEventEmitter.getInstance().sendEvent(eventName, payload, queue);
    }

    /**
     * Send a notification opened event
     * @param notificationMap
     */
    private void sendNotification(WritableMap notificationMap) {
        if (notificationMap != null) {
            WritableMap payload = Arguments.createMap();
            payload.putMap("notification", notificationMap);
            sendEvent("notificationOpened", payload, true);
        }
    }

    // React methods


    /**
     * Launch the module, alias for mount()
     * @see #mount()
     */
    @ReactMethod
    public void launch() {
        if (!mounted) {
            mount();
        }
    }

    /**
     * Mount the module, listen for ready events and process event queue
     */
    @ReactMethod
    public void mount() {
        mounted = true;
        NotificareEventEmitter.getInstance().setMounted(true);
        Notificare.shared().addNotificareReadyListener(this);
        NotificareEventEmitter.getInstance().processEventQueue();
    }

    /**
     * Unmount the module, stop listening for ready events and queue incoming events
     */
    @ReactMethod
    public void unmount() {
        mounted = false;
        NotificareEventEmitter.getInstance().setMounted(false);
        Notificare.shared().removeNotificareReadyListener(this);
    }

    /**
     * Enable notifications, alias for enableNotifications
     * @see #enableNotifications()
     */
    @ReactMethod
    public void registerForNotifications() {
        enableNotifications();
    }

    /**
     * Enable notifications
     */
    @ReactMethod
    public void enableNotifications() {
        Notificare.shared().enableNotifications();
    }

    /**
     * Disable notifications
     */
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
    public void isNotificationsEnabled(Callback callback) {
        callback.invoke(Notificare.shared().isNotificationsEnabled());
    }

    @ReactMethod
    public void isLocationUpdatesEnabled(Callback callback) {
        callback.invoke(Notificare.shared().isLocationUpdatesEnabled());
    }

    @ReactMethod
    public void fetchNotificationSettings(Callback callback) {
        callback.invoke(Notificare.shared().checkAllowedUI());
    }

    /**
     * Register device with Notificare API
     * @param deviceId
     * @param userId
     * @param userName
     * @param callback
     */
    @ReactMethod
    public void registerDevice( String deviceId, String userId, String userName, final Callback callback) {
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

    /**
     * Get device info
     * @param callback
     */
    @ReactMethod
    public void fetchDevice(Callback callback) {
        WritableMap map = Arguments.createMap();
        map.putString("deviceID", Notificare.shared().getDeviceId());
        map.putString("username", Notificare.shared().getUserName());
        map.putString("userID", Notificare.shared().getUserId());
        callback.invoke(null, map);
    }

    /**
     * Open notification in a NotificationActivity
     * @param notification
     */
    @ReactMethod
    public void openNotification(ReadableMap notification) {
        Log.i(TAG, "trying to open notification");
        if (notification.hasKey("id")) {
            String notificationId = notification.getString("id");
            if (notification.hasKey("inboxItemId") && notification.getString("inboxItemId") != null && !notification.getString("inboxItemId").isEmpty() && Notificare.shared().getInboxManager() != null) {
                Log.i(TAG, "open with inbox id");
                // This is an item opened with inboxItemId, so coming from NotificationManager open
                NotificareInboxItem notificareInboxItem = Notificare.shared().getInboxManager().getItem(notification.getString("inboxItemId"));
                if (notificareInboxItem != null) {
                    Notificare.shared().openInboxItem(getCurrentActivity(), notificareInboxItem);
                    Notificare.shared().getInboxManager().markItem(notificareInboxItem);
                }
            } else if (notificationId != null && !notificationId.isEmpty()) {
                Log.i(TAG, "try open as is");
                // We have a notificationId, let's see if we can create a notification from the payload, otherwise fetch from API
                NotificareNotification notificareNotification = NotificareUtils.createNotification(notification);
                if (notificareNotification != null) {
                    try {
                        Log.i(TAG, notificareNotification.toJSONObject().toString());
                    } catch (JSONException e) {

                    }
                    Notificare.shared().openNotification(getCurrentActivity(), notificareNotification);
                } else {
                    Notificare.shared().fetchNotification(notificationId, new NotificareCallback<NotificareNotification>() {
                        @Override
                        public void onSuccess(NotificareNotification notificareNotification) {
                            Notificare.shared().openNotification(getCurrentActivity(), notificareNotification);
                        }

                        @Override
                        public void onError(NotificareError notificareError) {
                            Log.e(TAG, "error fetching notification: " + notificareError.getMessage());
                        }
                    });
                }
            }
        } else {
            Log.i(TAG, "no id");
        }
    }

    /**
     * Fetch inbox items
     * @param date
     * @param skip
     * @param limit
     * @param callback
     */
    @ReactMethod
    public void fetchInbox(@Nullable String date, @Nullable int skip, @Nullable int limit, final Callback callback) {
        if (Notificare.shared().getInboxManager() != null) {
            int size = Notificare.shared().getInboxManager().getItems().size();
            if (limit <= 0) {
                limit = DEFAULT_LIST_SIZE;
            }
            if (skip < 0) {
                skip = 0;
            }
            if (skip > size) {
                skip = size;
            }
            int end = limit + skip;
            if (end > size) {
                end = size;
            }
            List<NotificareInboxItem> items = new ArrayList<NotificareInboxItem>(Notificare.shared().getInboxManager().getItems()).subList(skip, end);
            WritableArray inbox = Arguments.createArray();
            for (NotificareInboxItem item : items) {
                inbox.pushMap(NotificareUtils.mapInboxItem(item));
            }
            WritableMap payload = Arguments.createMap();
            payload.putArray("inbox", inbox);
            payload.putInt("total", size);
            payload.putInt("unread", Notificare.shared().getInboxManager().getUnreadCount());
            callback.invoke(null, payload);
        } else {
            callback.invoke("inbox not enabled", null);
        }
    }

    @ReactMethod
    public void openInboxItem(ReadableMap inboxItem, final Callback callback) {
        if (Notificare.shared().getInboxManager() != null) {
            NotificareInboxItem notificareInboxItem = Notificare.shared().getInboxManager().getItem(inboxItem.getString("inboxId"));
            if (notificareInboxItem != null) {
                Notificare.shared().openInboxItem(getCurrentActivity(), notificareInboxItem);
                Notificare.shared().getInboxManager().markItem(notificareInboxItem);
            } else {
                callback.invoke("inbox item not found", null);
            }
        } else {
            callback.invoke("inbox not enabled", null);
        }
    }

    @ReactMethod
    public void fetchNotificationForInboxItem(ReadableMap inboxItem, final Callback callback) {
        if (Notificare.shared().getInboxManager() != null) {
            NotificareInboxItem notificareInboxItem = Notificare.shared().getInboxManager().getItem(inboxItem.getString("inboxId"));
            if (notificareInboxItem != null) {
                callback.invoke(null, NotificareUtils.mapNotification(notificareInboxItem.getNotification()));
            } else {
                callback.invoke("inbox item not found", null);
            }
        } else {
            callback.invoke("inbox not enabled", null);
        }
    }

    @ReactMethod
    public void removeFromInbox(ReadableMap inboxItem, final Callback callback) {
        if (Notificare.shared().getInboxManager() != null) {
            final NotificareInboxItem notificareInboxItem = Notificare.shared().getInboxManager().getItem(inboxItem.getString("inboxId"));
            if (notificareInboxItem != null) {
                Notificare.shared().deleteInboxItem(notificareInboxItem.getItemId(), new NotificareCallback<Boolean>() {
                    @Override
                    public void onSuccess(Boolean result) {
                        Notificare.shared().getInboxManager().removeItem(notificareInboxItem);
                    }

                    @Override
                    public void onError(NotificareError error) {
                        callback.invoke("error removing inbox item");
                    }
                });
            } else {
                callback.invoke("inbox item not found", null);
            }
        } else {
            callback.invoke("inbox not enabled", null);
        }
    }

    @ReactMethod
    public void markAsRead(ReadableMap inboxItem, final Callback callback) {
        if (Notificare.shared().getInboxManager() != null) {
            final NotificareInboxItem notificareInboxItem = Notificare.shared().getInboxManager().getItem(inboxItem.getString("inboxId"));
            if (notificareInboxItem != null) {
                Notificare.shared().getEventLogger().logOpenNotification(notificareInboxItem.getNotification().getNotificationId());
                Notificare.shared().getInboxManager().markItem(notificareInboxItem);
                callback.invoke(null, "inbox item marked as read");
            } else {
                callback.invoke("inbox item not found", null);
            }
        } else {
            callback.invoke("inbox not enabled", null);
        }
    }

    @ReactMethod
    public void clearInbox(final Callback callback) {
        if (Notificare.shared().getInboxManager() != null) {
            Notificare.shared().clearInbox(new NotificareCallback<Boolean>() {
                @Override
                public void onSuccess(Boolean result) {
                    Notificare.shared().getInboxManager().clearInbox();
                    callback.invoke(null, "inbox cleared");
                }

                @Override
                public void onError(NotificareError error) {
                    callback.invoke("error clearing inbox");
                }
            });
        } else {
            callback.invoke("inbox not enabled", null);
        }
    }

    @ReactMethod
    public void fetchTags(final Callback callback) {
        Notificare.shared().fetchDeviceTags(new NotificareCallback<List<String>>() {
            @Override
            public void onError(NotificareError notificareError) {
                callback.invoke(notificareError.getMessage(), null);
            }

            @Override
            public void onSuccess(List<String> tags) {
                WritableArray tagsArray = Arguments.createArray();
                WritableMap payload = Arguments.createMap();

                for (String tag : tags) {
                    tagsArray.pushString(tag);
                }

                payload.putArray("tags", tagsArray);
                callback.invoke(null, payload);
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

                WritableArray assetsArray = Arguments.createArray();
                WritableMap payload = Arguments.createMap();

                for (NotificareAsset asset : notificareAssets) {
                    assetsArray.pushMap(NotificareUtils.mapAsset(asset));
                }

                payload.putArray("assets", assetsArray);
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
            public void onSuccess(NotificareTimeOfDayRange dnd) {
                WritableMap payload = Arguments.createMap();
                payload.putMap("dnd", NotificareUtils.mapTimeOfDayRange(dnd));
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

    /**
     * Log an open of notification
     * @param notificationId
     * @param callback
     */
    @ReactMethod
    public void logOpenNotification(String notificationId, Callback callback) {
        Notificare.shared().getEventLogger().logOpenNotification(notificationId);
        callback.invoke(null, "open notification logged");
    }

    /**
     * Log an influenced open of notification
     * @param notificationId
     * @param callback
     */
    @ReactMethod
    public void logOpenNotificationInfluenced(String notificationId, Callback callback) {
        Notificare.shared().getEventLogger().logOpenNotificationInfluenced(notificationId);
        callback.invoke(null, "influenced open notification logged");
    }

    /**
     * Log a custom event
     * @param name
     * @param data
     * @param callback
     */
    @ReactMethod
    public void logCustomEvent(String name, @Nullable ReadableMap data, Callback callback) {
        Notificare.shared().getEventLogger().logCustomEvent(name, NotificareUtils.createMap(data));
        callback.invoke(null, "custom event logged");
    }

    /**
     * Buy a product
     * @param product
     */
    @ReactMethod
    public void buyProduct(ReadableMap product) {
        NotificareProduct notificareProduct = Notificare.shared().getBillingManager().getProduct(product.getString("identifier"));
        Notificare.shared().getBillingManager().launchPurchaseFlow(getCurrentActivity(), notificareProduct, this);
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

        if (Notificare.shared().getBillingManager() != null && Notificare.shared().getBillingManager().handleActivityResult(requestCode, resultCode, data)) {
            // Billingmanager handled the result
            isBillingReady = true; // wait for purchase to finish before doing other calls
        }
    }

    /**
     * Called when a new intent is passed to the activity
     *
     * @param intent
     */
    @Override
    public void onNewIntent(Intent intent) {
        Log.d(TAG, "received new intent for activity " + getCurrentActivity());
        // Check for launch with notification or tokens
        WritableMap notificationMap = parseNotificationIntent(intent);
        if (notificationMap != null) {
            sendNotification(notificationMap);
            getCurrentActivity().setIntent(null);
        } else {
            getCurrentActivity().setIntent(intent);
        }
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
        Log.d(TAG, "host resume for activity " + getCurrentActivity());
        Notificare.shared().addServiceErrorListener(this);
        Notificare.shared().setForeground(true);
        Notificare.shared().addNotificationReceivedListener(this);
        Notificare.shared().getEventLogger().logStartSession();
        Notificare.shared().addBillingReadyListener(this);
        if (getCurrentActivity().getIntent() != null) {
            WritableMap notificationMap = parseNotificationIntent(getCurrentActivity().getIntent());
            if (notificationMap != null) {
                sendNotification(notificationMap);
                getCurrentActivity().setIntent(null);
            }
        }
    }

    /**
     * Called when host activity receives pause event (e.g. {@link Activity#onPause}. Always called
     * for the most current activity.
     */
    @Override
    public void onHostPause() {
        Log.d(TAG, "host pause for activity " + getCurrentActivity());
        Notificare.shared().removeServiceErrorListener(this);
        Notificare.shared().removeNotificationReceivedListener(this);
        Notificare.shared().setForeground(false);
        Notificare.shared().getEventLogger().logEndSession();
        Notificare.shared().removeBillingReadyListener(this);
    }

    /**
     * Called when host activity receives destroy event (e.g. {@link Activity#onDestroy}. Only called
     * for the last React activity to be destroyed.
     */
    @Override
    public void onHostDestroy() {
        Log.d(TAG, "host destroy for activity " + getCurrentActivity());
        Notificare.shared().removeServiceErrorListener(this);
        Notificare.shared().removeNotificationReceivedListener(this);
        Notificare.shared().setForeground(false);
        Notificare.shared().getEventLogger().logEndSession();
    }

    // OnNotificareReadyListener

    @Override
    public void onNotificareReady(NotificareApplicationInfo notificareApplicationInfo) {
        WritableMap payload = Arguments.createMap();
        payload.putMap("application", NotificareUtils.mapApplicationInfo(notificareApplicationInfo));
        sendEvent("ready", payload, true);
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
    public void onNotificationReceived(NotificareNotification notification) {
        if (notification != null) {
            WritableMap notificationMap = NotificareUtils.mapNotification(notification);
            sendEvent("notificationReceived", notificationMap, true);
        }
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
            WritableMap notificationMap = NotificareUtils.mapNotification(notification);
            // Add inbox item id if present
            if (intent.hasExtra(Notificare.INTENT_EXTRA_INBOX_ITEM_ID)) {
                notificationMap.putString("inboxItemId", intent.getStringExtra(Notificare.INTENT_EXTRA_INBOX_ITEM_ID));
            }
            return notificationMap;
        }
        return null;
    }


    @Override
    public void onBillingReady() {
        if (!isBillingReady) {
            Notificare.shared().getBillingManager().refresh(this);
        }
    }

    @Override
    public void onPurchaseFinished(BillingResult billingResult, Purchase purchase) {
        isBillingReady = false;
        Notificare.shared().getBillingManager().refresh(this);
    }

    @Override
    public void onRefreshFinished() {
        WritableMap payload = Arguments.createMap();
        List<NotificareProduct> list = Notificare.shared().getBillingManager().getProducts();
        payload.putArray("products", NotificareUtils.mapProducts(list));
        sendEvent("didLoadStore", payload, true);
    }

    @Override
    public void onRefreshFailed(NotificareError notificareError) {
        WritableMap payload = Arguments.createMap();
        payload.putString("error", notificareError.getMessage());
        sendEvent("didLoadStore", payload, true);
    }
}