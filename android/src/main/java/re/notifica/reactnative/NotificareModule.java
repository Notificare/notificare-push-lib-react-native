package re.notifica.reactnative;

import android.app.Activity;
import android.content.DialogInterface;
import android.content.Intent;
import android.os.Bundle;
import android.util.Log;

import com.facebook.react.bridge.ActivityEventListener;
import com.facebook.react.bridge.LifecycleEventListener;
import com.facebook.react.bridge.NativeModule;
import com.facebook.react.bridge.ReactApplicationContext;
import com.facebook.react.bridge.ReactContext;
import com.facebook.react.bridge.ReactContextBaseJavaModule;
import com.facebook.react.bridge.ReactMethod;
import com.facebook.react.bridge.Callback;
import com.facebook.react.bridge.Arguments;
import com.facebook.react.bridge.ReadableMap;
import com.facebook.react.bridge.WritableArray;
import java.util.List;
import re.notifica.Notificare;
import re.notifica.NotificareCallback;
import re.notifica.NotificareError;
import re.notifica.model.NotificareApplicationInfo;
import re.notifica.model.NotificareNotification;

public class NotificareModule extends ReactContextBaseJavaModule implements ActivityEventListener, LifecycleEventListener, Notificare.OnNotificareReadyListener, Notificare.OnServiceErrorListener, Notificare.OnNotificationReceivedListener {

    public NotificareModule(ReactApplicationContext reactContext) {
        super(reactContext);
        reactContext.addActivityEventListener(this);
        reactContext.addLifecycleEventListener(this);
        Notificare.shared().addServiceErrorListener(this);
        Notificare.shared().addNotificareReadyListener(this);
        Notificare.shared().setForeground(true);
        Notificare.shared().getEventLogger().logStartSession();
        // Check for launch with notification or tokens
//        sendNotification(parseNotificationIntent(getCurrentActivity().getIntent()));
//        sendValidateUserToken(Notificare.shared().parseValidateUserIntent(getCurrentActivity().getIntent()));
//        sendResetPasswordToken(Notificare.shared().parseResetPasswordIntent(getCurrentActivity().getIntent()));
    }

    @Override
    public String getName() {
        return "NotificareReactNativeAndroid";
    }

    @ReactMethod
    public void launch() {
//        Notificare.shared().launch(getReactApplicationContext());
//        Notificare.shared().setIntentReceiver(NotificareReceiver.class);
//        Notificare.shared().setAllowJavaScript(true);
    }

    @ReactMethod
    public void setCrashLogs(boolean logs) {
        Notificare.shared().setCrashLogs(logs);
    }

    @ReactMethod
    public void enableNotifications() {
        Notificare.shared().enableNotifications();
    }

    @ReactMethod
    public void enableLocationUpdates() {
        if (!Notificare.shared().hasLocationPermissionGranted()) {
            if (Notificare.shared().didRequestLocationPermission()) {
                if (Notificare.shared().shouldShowRequestPermissionRationale(getCurrentActivity())) {
                    // Here we should show a dialog explaining location updates
                    builder.setMessage(R.string.alert_location_permission_rationale)
                            .setTitle(R.string.app_name)
                            .setCancelable(true)
                            .setPositiveButton(R.string.button_location_permission_rationale_ok, new DialogInterface.OnClickListener() {
                                public void onClick(DialogInterface dialog, int id) {
                                    Notificare.shared().requestLocationPermission(MainActivity.this, LOCATION_PERMISSION_REQUEST_CODE);
                                }
                            })
                            .create()
                            .show();
                }
            } else {
                Notificare.shared().requestLocationPermission(this, LOCATION_PERMISSION_REQUEST_CODE);
            }
        }



        if (!Notificare.shared().hasLocationPermissionGranted()) {
            Log.i(TAG, "permission not granted");
            getCurrentActivity().requestPermissions(this, LOCATION_PERMISSION_REQUEST_CODE, new String[]{android.Manifest.permission.ACCESS_FINE_LOCATION});
        } else {
            Notificare.shared().enableLocationUpdates();
        }
    }

    @ReactMethod
    public void enableBeacons(int rate) {
        Notificare.shared().enableBeacons(rate);
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
    public void fetchTags( final Callback callback ) {

        Notificare.shared().fetchDeviceTags(new NotificareCallback<List<String>>() {

            @Override
            public void onError(NotificareError arg0) {

                callback.invoke(arg0.getMessage(), null);

            }

            @Override
            public void onSuccess(List<String> arg0) {

                WritableArray map = Arguments.createArray();

                for (String tag : arg0) {
                    map.pushString(tag);
                }

                callback.invoke(null, map);

            }

        });


    }

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
        // Check for launch with notification or tokens
//        sendNotification(parseNotificationIntent(intent));
//        sendValidateUserToken(Notificare.shared().parseValidateUserIntent(intent));
//        sendResetPasswordToken(Notificare.shared().parseResetPasswordIntent(intent));
    }

    /**
     * Called either when the host activity receives a resume event (e.g. {@link Activity#onResume} or
     * if the native module that implements this is initialized while the host activity is already
     * resumed. Always called for the most current activity.
     */
    @Override
    public void onHostResume() {
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
        Notificare.shared().removeServiceErrorListener(this);
        Notificare.shared().removeNotificationReceivedListener(this);
        Notificare.shared().setForeground(false);
        Notificare.shared().getEventLogger().logEndSession();
    }

    @Override
    public void onNotificareReady(NotificareApplicationInfo notificareApplicationInfo) {
        NotificareEventEmitter.getInstance().sendEvent("onReady", null);
    }

    @Override
    public void onServiceError(int errorCode, int requestCode) {
        if (Notificare.isUserRecoverableError(errorCode).booleanValue()) {
            Notificare.getErrorDialog(errorCode, getCurrentActivity(), requestCode).show();
        }
    }

    @Override
    public void onNotificationReceived(NotificareNotification notificareNotification) {
        // TODO: serialize notification to event arguments
        //NotificareEventEmitter.getInstance().sendEvent("onNotificationReceived", notificareNotification);
    }
}