package re.notifica.reactnative;

import android.os.Bundle;
import android.util.Log;
import android.support.annotation.Nullable;
import com.facebook.react.bridge.Arguments;
import com.facebook.react.bridge.ReactContext;
import com.facebook.react.bridge.ReadableMap;
import com.facebook.react.modules.core.DeviceEventManagerModule;

public class NotificareEventEmitter {

    private static final String TAG = "NotificareEventEmitter";

    private static NotificareEventEmitter INSTANCE = null;

    private ReactContext context;

    private NotificareEventEmitter(ReactContext reactContext) {
        this.context = reactContext;
    }

    public void sendEvent(String eventName) {
        sendEvent(eventName, (ReadableMap)null);
    }

    public void sendEvent(String eventName, Boolean queue) {
        sendEvent(eventName, null, queue);
    }

    public void sendEvent(String eventName, @Nullable ReadableMap params) {
        sendEvent(eventName, params, false);
    }

    public void sendEvent(String eventName, @Nullable ReadableMap params, Boolean queue) {
        Log.i(TAG, "send event " + eventName);
        if (context.hasActiveCatalystInstance() && this.context.hasCurrentActivity()) {
            Log.i(TAG, "sent event to " + this.context.getCurrentActivity());
            context.getJSModule(DeviceEventManagerModule.RCTDeviceEventEmitter.class).emit(
                    eventName, params
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
