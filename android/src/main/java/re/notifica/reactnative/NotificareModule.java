package re.notifica.reactnative;

import android.app.Activity;
import android.content.Intent;

import com.facebook.react.bridge.ActivityEventListener;
import com.facebook.react.bridge.Arguments;
import com.facebook.react.bridge.Callback;
import com.facebook.react.bridge.LifecycleEventListener;
import com.facebook.react.bridge.Promise;
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
import re.notifica.beacon.BeaconRangingListener;
import re.notifica.billing.BillingManager;
import re.notifica.billing.BillingResult;
import re.notifica.billing.Purchase;
import re.notifica.model.NotificareAction;
import re.notifica.model.NotificareApplicationInfo;
import re.notifica.model.NotificareAsset;
import re.notifica.model.NotificareBeacon;
import re.notifica.model.NotificareInboxItem;
import re.notifica.model.NotificareNotification;
import re.notifica.model.NotificareProduct;
import re.notifica.model.NotificareTimeOfDay;
import re.notifica.model.NotificareTimeOfDayRange;
import re.notifica.model.NotificareUserData;
import re.notifica.model.NotificareUserDataField;
import re.notifica.util.Log;

class NotificareModule extends ReactContextBaseJavaModule implements ActivityEventListener, LifecycleEventListener, Notificare.OnNotificareReadyListener, Notificare.OnServiceErrorListener, Notificare.OnNotificationReceivedListener, BeaconRangingListener, Notificare.OnBillingReadyListener, BillingManager.OnRefreshFinishedListener, BillingManager.OnPurchaseFinishedListener {

    private static final String TAG = NotificareModule.class.getSimpleName();
    private static final int DEFAULT_LIST_SIZE = 25;

    private static final String DEFAULT_ERROR_CODE = "notificare_error";

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
    public void sendEvent(String eventName, Object payload) {
        sendEvent(eventName, payload, false);
    }

    /**
     * Send an event to the JS context
     * @param eventName
     * @param payload
     * @param queue
     */
    private void sendEvent(String eventName, Object payload, Boolean queue) {
        NotificareEventEmitter.getInstance().sendEvent(eventName, payload, queue);
    }

    /**
     * Send a notification opened event
     * @param notificationMap
     */
    private void sendNotification(ReadableMap notificationMap) {
        if (notificationMap != null) {
            sendEvent("notificationOpened", notificationMap, true);
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
    public void unregisterForNotifications() {
        Notificare.shared().disableNotifications();
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
    public void startLocationUpdates() {
        Notificare.shared().enableLocationUpdates();
    }

    @ReactMethod
    public void disableLocationUpdates() {
        Notificare.shared().disableLocationUpdates();
    }

    @ReactMethod
    public void stopLocationUpdates() {
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
    public void isNotificationsEnabled(Promise promise) {
        promise.resolve(Notificare.shared().isNotificationsEnabled());
    }

    @ReactMethod
    public void isLocationUpdatesEnabled(Promise promise) {
        promise.resolve(Notificare.shared().isLocationUpdatesEnabled());
    }

    @ReactMethod
    public void fetchNotificationSettings(Promise promise) {
        promise.resolve(Notificare.shared().checkAllowedUI());
    }

    /**
     * Register device with Notificare API
     * @param deviceId
     * @param userId
     * @param userName
     * @param promise
     */
    @ReactMethod
    public void registerDevice(String deviceId, String userId, String userName, final Promise promise) {
        Notificare.shared().registerDevice(deviceId, userId, userName, new NotificareCallback<String>() {
            @Override
            public void onSuccess(String result) {
                promise.resolve(NotificareUtils.mapDevice(Notificare.shared().getRegisteredDevice()));
            }

            @Override
            public void onError(NotificareError error) {
                promise.reject(DEFAULT_ERROR_CODE, error);
            }
        });
    }

    /**
     * Get device info
     * @param promise
     */
    @ReactMethod
    public void fetchDevice(Promise promise) {
        promise.resolve(NotificareUtils.mapDevice(Notificare.shared().getRegisteredDevice()));
    }

    @ReactMethod
    public void fetchTags(final Promise promise) {
        Notificare.shared().fetchDeviceTags(new NotificareCallback<List<String>>() {
            @Override
            public void onError(NotificareError notificareError) {
                promise.reject(DEFAULT_ERROR_CODE, notificareError);
            }

            @Override
            public void onSuccess(List<String> tags) {
                promise.resolve(Arguments.fromArray(tags));
            }
        });
    }

    @ReactMethod
    public void addTag(String tag, final Promise promise ) {

        Notificare.shared().addDeviceTag(tag, new NotificareCallback<Boolean>() {
            @Override
            public void onSuccess(Boolean aBoolean) {
                promise.resolve(null);
            }

            @Override
            public void onError(NotificareError notificareError) {
                promise.reject(DEFAULT_ERROR_CODE, notificareError);
            }
        });

    }

    @ReactMethod
    public void addTags(ReadableArray tags, final Promise promise ) {

        List<String> theTags = new ArrayList<>(tags.size());
        for (int i = 0; i < tags.size(); i++) {
            theTags.add(tags.getString(i));
        }
        Notificare.shared().addDeviceTags(theTags, new NotificareCallback<Boolean>() {
            @Override
            public void onSuccess(Boolean aBoolean) {
                promise.resolve(null);
            }

            @Override
            public void onError(NotificareError notificareError) {
                promise.reject(DEFAULT_ERROR_CODE, notificareError);
            }
        });

    }

    @ReactMethod
    public void removeTag(String tag, final Promise promise ) {

        Notificare.shared().removeDeviceTag(tag, new NotificareCallback<Boolean>() {
            @Override
            public void onSuccess(Boolean aBoolean) {
                promise.resolve(null);
            }

            @Override
            public void onError(NotificareError notificareError) {
                promise.reject(DEFAULT_ERROR_CODE, notificareError);
            }
        });

    }

    @ReactMethod
    public void removeTags(ReadableArray tags, final Promise promise ) {

        List<String> theTags = new ArrayList<>(tags.size());
        for (int i = 0; i < tags.size(); i++) {
            theTags.add(tags.getString(i));
        }
        Notificare.shared().removeDeviceTags(theTags, new NotificareCallback<Boolean>() {
            @Override
            public void onSuccess(Boolean aBoolean) {
                promise.resolve(null);
            }

            @Override
            public void onError(NotificareError notificareError) {
                promise.reject(DEFAULT_ERROR_CODE, notificareError);
            }
        });

    }

    @ReactMethod
    public void clearTags(final Promise promise) {

        Notificare.shared().clearDeviceTags(new NotificareCallback<Boolean>() {
            @Override
            public void onSuccess(Boolean aBoolean) {
                promise.resolve(null);
            }

            @Override
            public void onError(NotificareError notificareError) {
                promise.reject(DEFAULT_ERROR_CODE, notificareError);
            }
        });

    }

    @ReactMethod
    public void fetchUserData(final Promise promise) {

        Notificare.shared().fetchUserData(new NotificareCallback<NotificareUserData>() {
            @Override
            public void onSuccess(NotificareUserData notificareUserData) {
                WritableArray userDataFields = Arguments.createArray();
                for (HashMap.Entry<String, NotificareUserDataField> field : Notificare.shared().getApplicationInfo().getUserDataFields().entrySet()) {
                    WritableMap userDataMap = Arguments.createMap();
                    userDataMap.putString("key", field.getValue().getKey());
                    userDataMap.putString("label", field.getValue().getLabel());
                    userDataMap.putString("value", notificareUserData.getValue(field.getKey()));
                    userDataFields.pushMap(userDataMap);
                }
                promise.resolve(userDataFields);
            }

            @Override
            public void onError(NotificareError notificareError) {
                promise.reject(DEFAULT_ERROR_CODE, notificareError);
            }
        });
    }

    @ReactMethod
    public void updateUserData(ReadableMap userData, final Promise promise) {

        Map<String, Object> fields = NotificareUtils.createMap(userData);
        NotificareUserData data = new NotificareUserData();
        for (String key : fields.keySet()) {
            if (fields.get(key) != null) {
                data.setValue(key, fields.get(key).toString());
            }
        }

        Notificare.shared().updateUserData(data, new NotificareCallback<Boolean>() {
            @Override
            public void onSuccess(Boolean aBoolean) {
                promise.resolve(null);
            }

            @Override
            public void onError(NotificareError notificareError) {
                promise.reject(DEFAULT_ERROR_CODE, notificareError);
            }
        });
    }


    @ReactMethod
    public void fetchDoNotDisturb(final Promise promise) {

        Notificare.shared().fetchDoNotDisturb(new NotificareCallback<NotificareTimeOfDayRange>() {
            @Override
            public void onSuccess(NotificareTimeOfDayRange dnd) {
                promise.resolve(NotificareUtils.mapTimeOfDayRange(dnd));
            }

            @Override
            public void onError(NotificareError notificareError) {
                promise.reject(DEFAULT_ERROR_CODE, notificareError);
            }
        });
    }

    @ReactMethod
    public void updateDoNotDisturb(ReadableMap deviceDnd, final Promise promise) {

        if (deviceDnd.getString("start") != null && deviceDnd.getString("end") != null) {
            String[] s = deviceDnd.getString("start").split(":");
            String[] e = deviceDnd.getString("end").split(":");
            final NotificareTimeOfDayRange range = new NotificareTimeOfDayRange(
                    new NotificareTimeOfDay(Integer.parseInt(s[0]),Integer.parseInt(s[1])),
                    new NotificareTimeOfDay(Integer.parseInt(e[0]),Integer.parseInt(e[1])));

            Notificare.shared().updateDoNotDisturb(range, new NotificareCallback<Boolean>() {
                @Override
                public void onSuccess(Boolean aBoolean) {
                    promise.resolve(NotificareUtils.mapTimeOfDayRange(range));
                }

                @Override
                public void onError(NotificareError notificareError) {
                    promise.reject(DEFAULT_ERROR_CODE, notificareError);
                }
            });
        } else {
            promise.reject(DEFAULT_ERROR_CODE, new NotificareError("invalid device dnd"));
        }

    }

    @ReactMethod
    public void clearDoNotDisturb(final Promise promise) {

        Notificare.shared().clearDoNotDisturb(new NotificareCallback<Boolean>() {
            @Override
            public void onSuccess(Boolean aBoolean) {
                promise.resolve(null);
            }

            @Override
            public void onError(NotificareError notificareError) {
                promise.reject(DEFAULT_ERROR_CODE, notificareError);
            }
        });
    }

    @ReactMethod
    public void fetchNotificationForInboxItem(ReadableMap inboxItem, final Promise promise) {
        if (Notificare.shared().getInboxManager() != null) {
            NotificareInboxItem notificareInboxItem = Notificare.shared().getInboxManager().getItem(inboxItem.getString("inboxId"));
            if (notificareInboxItem != null) {
                promise.resolve(NotificareUtils.mapNotification(notificareInboxItem.getNotification()));
            } else {
                promise.reject(DEFAULT_ERROR_CODE, new NotificareError("inbox item not found"));
            }
        } else {
            promise.reject(DEFAULT_ERROR_CODE, new NotificareError("inbox not enabled"));
        }
    }

    /**
     * Open notification in a NotificationActivity
     * @param notification
     */
    @ReactMethod
    public void presentNotification(ReadableMap notification) {
        openNotification(notification);
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
     * @param promise
     */
    @ReactMethod
    public void fetchInbox(Promise promise) {
        if (Notificare.shared().getInboxManager() != null) {
            WritableArray inbox = Arguments.createArray();
            for (NotificareInboxItem item : Notificare.shared().getInboxManager().getItems()) {
                inbox.pushMap(NotificareUtils.mapInboxItem(item));
            }
            promise.resolve(inbox);
        } else {
            promise.reject(DEFAULT_ERROR_CODE, new NotificareError("inbox not enabled"));
        }
    }

    @ReactMethod
    public void presentInboxItem(ReadableMap inboxItem) {
        openInboxItem(inboxItem);
    }

    @ReactMethod
    public void openInboxItem(ReadableMap inboxItem) {
        if (Notificare.shared().getInboxManager() != null) {
            NotificareInboxItem notificareInboxItem = Notificare.shared().getInboxManager().getItem(inboxItem.getString("inboxId"));
            if (notificareInboxItem != null) {
                Notificare.shared().openInboxItem(getCurrentActivity(), notificareInboxItem);
            }
        }
    }


    @ReactMethod
    public void removeFromInbox(ReadableMap inboxItem, final Promise promise) {
        if (Notificare.shared().getInboxManager() != null) {
            NotificareInboxItem notificareInboxItem = Notificare.shared().getInboxManager().getItem(inboxItem.getString("inboxId"));
            if (notificareInboxItem != null) {
                Notificare.shared().getInboxManager().removeItem(notificareInboxItem, new NotificareCallback<Boolean>() {
                    @Override
                    public void onSuccess(Boolean result) {
                        promise.resolve(null);
                    }

                    @Override
                    public void onError(NotificareError error) {
                        promise.reject(DEFAULT_ERROR_CODE, error);
                    }
                });
            } else {
                promise.reject(DEFAULT_ERROR_CODE, new NotificareError("inbox item not found"));
            }
        } else {
            promise.reject(DEFAULT_ERROR_CODE, new NotificareError("inbox not enabled"));
        }
    }

    @ReactMethod
    public void markAsRead(ReadableMap inboxItem, final Promise promise) {
        if (Notificare.shared().getInboxManager() != null) {
            NotificareInboxItem notificareInboxItem = Notificare.shared().getInboxManager().getItem(inboxItem.getString("inboxId"));
            if (notificareInboxItem != null) {
                Notificare.shared().getInboxManager().markItem(notificareInboxItem, new NotificareCallback<Boolean>() {
                    @Override
                    public void onSuccess(Boolean aBoolean) {
                        promise.resolve(null);
                    }

                    @Override
                    public void onError(NotificareError error) {
                        promise.reject(DEFAULT_ERROR_CODE, error);
                    }
                });
            } else {
                promise.reject(DEFAULT_ERROR_CODE, new NotificareError("inbox item not found"));
            }
        } else {
            promise.reject(DEFAULT_ERROR_CODE, new NotificareError("inbox not enabled"));
        }
    }

    @ReactMethod
    public void clearInbox(final Promise promise) {
        if (Notificare.shared().getInboxManager() != null) {
            Notificare.shared().getInboxManager().clearInbox(new NotificareCallback<Integer>() {
                @Override
                public void onSuccess(Integer result) {
                    promise.resolve(result);
                }

                @Override
                public void onError(NotificareError error) {
                    promise.reject(DEFAULT_ERROR_CODE, error);
                }
            });
        } else {
            promise.reject(DEFAULT_ERROR_CODE, new NotificareError("inbox not enabled"));
        }
    }

    @ReactMethod
    public void fetchAssets(String query, final Promise promise){

        Notificare.shared().fetchAssets(query, new NotificareCallback<List<NotificareAsset>>() {
            @Override
            public void onSuccess(List<NotificareAsset> notificareAssets) {

                WritableArray assetsArray = Arguments.createArray();
                for (NotificareAsset asset : notificareAssets) {
                    assetsArray.pushMap(NotificareUtils.mapAsset(asset));
                }
                promise.resolve(assetsArray);

            }

            @Override
            public void onError(NotificareError notificareError) {
                promise.reject(DEFAULT_ERROR_CODE, notificareError);
            }

        });
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

    /**
     * Log a custom event
     * @param name
     * @param data
     * @param promise
     */
    @ReactMethod
    public void logCustomEvent(String name, @Nullable ReadableMap data, final Promise promise) {
        Notificare.shared().getEventLogger().logCustomEvent(name, NotificareUtils.createMap(data), new NotificareCallback<Boolean>() {
            @Override
            public void onSuccess(Boolean aBoolean) {
                promise.resolve(null);
            }

            @Override
            public void onError(NotificareError notificareError) {
                promise.reject(DEFAULT_ERROR_CODE, notificareError);
            }
        });
    }

    /**
     * Log an open of notification
     * @param notification
     * @param promise
     */
    @ReactMethod
    public void logOpenNotification(ReadableMap notification, final Promise promise) {
        NotificareNotification theNotification = NotificareUtils.createNotification(notification);
        if (theNotification != null) {
            Notificare.shared().getEventLogger().logOpenNotification(theNotification.getNotificationId(), new NotificareCallback<Boolean>() {
                @Override
                public void onSuccess(Boolean aBoolean) {
                    promise.resolve(null);
                }

                @Override
                public void onError(NotificareError notificareError) {
                    promise.reject(DEFAULT_ERROR_CODE, notificareError);
                }
            });
        } else {
            promise.reject(DEFAULT_ERROR_CODE, new NotificareError("invalid notification"));
        }
    }

    /**
     * Log an influenced open of notification
     * @param notification
     * @param promise
     */
    @ReactMethod
    public void logOpenNotificationInfluenced(ReadableMap notification, final Promise promise) {
        NotificareNotification theNotification = NotificareUtils.createNotification(notification);
        if (theNotification != null) {
            Notificare.shared().getEventLogger().logOpenNotificationInfluenced(theNotification.getNotificationId(), new NotificareCallback<Boolean>() {
                @Override
                public void onSuccess(Boolean aBoolean) {
                    promise.resolve(null);
                }

                @Override
                public void onError(NotificareError notificareError) {
                    promise.reject(DEFAULT_ERROR_CODE, notificareError);
                }
            });
        } else {
            promise.reject(DEFAULT_ERROR_CODE, new NotificareError("invalid notification"));
        }
    }

    // ActivityEventListener methods

    /**
     * Called when host (activity/service) receives an onActivityResult call.
     *
     * @param requestCode
     * @param resultCode
     * @param data
     */
    @Override
    public void onActivityResult(int requestCode, int resultCode, Intent data) {
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
        if (getCurrentActivity() != null) {
            if (notificationMap != null) {
                sendNotification(notificationMap);
                getCurrentActivity().setIntent(null);
            } else {
                getCurrentActivity().setIntent(intent);
            }
        }
//        sendValidateUserToken(Notificare.shared().parseValidateUserIntent(intent));
//        sendResetPasswordToken(Notificare.shared().parseResetPasswordIntent(intent));
    }

    // LifecycleEventListener methods

    /**
     * Called either when the host activity receives a resume event or
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
        if (Notificare.shared().getBeaconClient() != null) {
            Notificare.shared().getBeaconClient().addRangingListener(this);
        }
        Notificare.shared().addBillingReadyListener(this);
        if (getCurrentActivity() != null && getCurrentActivity().getIntent() != null) {
            WritableMap notificationMap = parseNotificationIntent(getCurrentActivity().getIntent());
            if (notificationMap != null) {
                sendNotification(notificationMap);
                getCurrentActivity().setIntent(null);
            }
        }
    }

    /**
     * Called when host activity receives pause event. Always called
     * for the most current activity.
     */
    @Override
    public void onHostPause() {
        Log.d(TAG, "host pause for activity " + getCurrentActivity());
        Notificare.shared().removeServiceErrorListener(this);
        Notificare.shared().removeNotificationReceivedListener(this);
        Notificare.shared().setForeground(false);
        Notificare.shared().getEventLogger().logEndSession();
        if (Notificare.shared().getBeaconClient() != null) {
            Notificare.shared().getBeaconClient().removeRangingListener(this);
        }
        Notificare.shared().removeBillingReadyListener(this);
    }

    /**
     * Called when host activity receives destroy event. Only called
     * for the last React activity to be destroyed.
     */
    @Override
    public void onHostDestroy() {
        Log.d(TAG, "host destroy for activity " + getCurrentActivity());
        Notificare.shared().removeServiceErrorListener(this);
        Notificare.shared().removeNotificationReceivedListener(this);
        Notificare.shared().setForeground(false);
        Notificare.shared().getEventLogger().logEndSession();
        if (Notificare.shared().getBeaconClient() != null) {
            Notificare.shared().getBeaconClient().removeRangingListener(this);
        }
        Notificare.shared().removeBillingReadyListener(this);
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
        if (Notificare.isUserRecoverableError(errorCode)) {
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
    public void onRangingBeacons(List<NotificareBeacon> list) {

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