package com.awesomeproject;

import android.os.Bundle;
import android.util.Log;

import com.facebook.react.bridge.Arguments;
import com.facebook.react.bridge.ReactContext;
import com.facebook.react.bridge.ReadableMap;
import com.facebook.react.modules.core.DeviceEventManagerModule;
import re.notifica.model.NotificareNotification;

public class NotificareEventEmitter {

    private static final String TAG = "NotificareEventEmitter";

    private static NotificareEventEmitter INSTANCE = null;

    private ReactContext context;

    private NotificareEventEmitter(ReactContext reactContext) {
        this.context = reactContext;
        this.context.addLifecycleEventListener(NotificareReceiverHelper.getInstance(context));
    }

    public void sendEvent(String eventName, NotificareNotification message) {
        if (context.hasActiveCatalystInstance() && this.context.hasCurrentActivity()) {
            context.getJSModule(DeviceEventManagerModule.RCTDeviceEventEmitter.class).emit(
                    "receivedNotification", message
            );
        }
    }

    public static void setup(ReactContext reactContext) {
        if (NotificareEventEmitter.INSTANCE == null) {
            NotificareEventEmitter.INSTANCE = new NotificareEventEmitter(reactContext);
        } else {
            Log.w(TAG, "Event Emitter initialized more than once");
            if (NotificareEventEmitter.INSTANCE.context.getCatalystInstance().isDestroyed()) {
                NotificareEventEmitter.INSTANCE = new NotificareEventEmitter(reactContext);
            }
        }
    }

    public static NotificareEventEmitter getInstance() {
        return NotificareEventEmitter.INSTANCE;
    }
}
