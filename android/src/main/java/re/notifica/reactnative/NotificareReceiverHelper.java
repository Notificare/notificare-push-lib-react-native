package re.notifica.reactnative;

import android.content.Context;
import android.content.Intent;

import com.facebook.react.bridge.LifecycleEventListener;


public class NotificareReceiverHelper implements LifecycleEventListener {

    private static NotificareReceiverHelper instance = null;
    private Context context;
    private Intent pushIntent;

    private NotificareReceiverHelper(Context context) {
        this.context = context;
    }

    public static synchronized NotificareReceiverHelper getInstance(Context context) {
        if (instance == null) {
            instance = new NotificareReceiverHelper(context);
        }
        return instance;
    }

    public void savePushIntent(Intent intent) {
        this.pushIntent = intent;
    }

    public void sendPushIntent() {
        if (pushIntent != null) {
            context.sendBroadcast(pushIntent);
            pushIntent = null;
        }
    }

    @Override
    public void onHostResume() {
        sendPushIntent();
    }

    @Override
    public void onHostPause() {
    }

    @Override
    public void onHostDestroy() {
    }
}
