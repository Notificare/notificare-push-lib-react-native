package re.notifica.reactnative;

import android.support.annotation.Nullable;
import android.util.Log;

import com.facebook.react.bridge.ReactContext;
import com.facebook.react.modules.core.DeviceEventManagerModule;

import java.util.ArrayList;
import java.util.List;

public class NotificareEventEmitter {

    private static final String TAG = "NotificareEventEmitter";

    private static NotificareEventEmitter INSTANCE = null;

    private static final Object lock = new Object();

    private ReactContext context;
    private Boolean mounted = false;
    private List<String> eventQueue;
    private List<Object> eventParamsQueue;
    private NotificareEventEmitter(ReactContext reactContext) {
        this.context = reactContext;
        this.eventQueue = new ArrayList<>();
        this.eventParamsQueue = new ArrayList<>();
    }

    /**
     * Set the component mounted
     * @param mounted
     */
    public void setMounted(Boolean mounted) {
        this.mounted = mounted;
    }

    /**
     * Send event to JS with no params and without queueing
     * @param eventName
     */
    public void sendEvent(String eventName) {
        sendEvent(eventName, null, false);
    }

    /**
     * Send event to JS with no params
     * @param eventName
     * @param queue
     */
    public void sendEvent(String eventName, Boolean queue) {
        sendEvent(eventName, null, queue);
    }

    /**
     * Send event to JS without queueing
     * @param eventName
     * @param params
     */
    public void sendEvent(String eventName, @Nullable Object params) {
        sendEvent(eventName, params, false);
    }

    /**
     * Send event to JS
     * @param eventName
     * @param params
     * @param queue
     */
    public void sendEvent(String eventName, @Nullable Object params, Boolean queue) {
        Log.i(TAG, "send event " + eventName);
        if (context != null && context.hasActiveCatalystInstance() && context.hasCurrentActivity() && mounted) {
            Log.i(TAG, "sent event to current activity");
            context.getJSModule(DeviceEventManagerModule.RCTDeviceEventEmitter.class).emit(eventName, params);
        } else if (queue) {
            Log.i(TAG, "queueing event until listeners ready");
            eventQueue.add(eventName);
            eventParamsQueue.add(params);
        }
    }

    /**
     * Process the queued events
     */
    public void processEventQueue() {
        for (int i = 0; i < eventQueue.size(); i++) {
            sendEvent(eventQueue.get(i), eventParamsQueue.get(i));
        }
        eventQueue.clear();
        eventParamsQueue.clear();
    }

    public static void setup(ReactContext reactContext) {
        Log.i(TAG, "notificare event emitter setup");
        synchronized (lock) {
            if (INSTANCE == null) {
                INSTANCE = new NotificareEventEmitter(reactContext);
            } else {
                Log.w(TAG, "Event Emitter initialized more than once");
                if (INSTANCE.context != null && INSTANCE.context.getCatalystInstance().isDestroyed()) {
                    INSTANCE = new NotificareEventEmitter(reactContext);
                } else {
                    INSTANCE.context = reactContext;
                }
            }
        }
    }

    public static NotificareEventEmitter getInstance() {

        synchronized (lock) {
            if (INSTANCE == null) {
                INSTANCE = new NotificareEventEmitter(null);
            }
            return INSTANCE;
        }
    }
}
