package re.notifica.reactnative;

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

public class NotificareModule extends ReactContextBaseJavaModule {

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
        //Notificare.shared().setSmallIcon(R.mipmap.ic_launcher);
        Notificare.shared().setAllowJavaScript(true);
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
        Notificare.shared().enableLocationUpdates();
    }

    @ReactMethod
    public void enableBeacons(int rate) {
        Notificare.shared().enableBeacons(rate);
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

}