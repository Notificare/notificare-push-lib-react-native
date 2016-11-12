package re.notifica.reactnative;

import com.facebook.react.bridge.ReadableMap;
import com.facebook.react.bridge.ReadableMapKeySetIterator;
import com.facebook.react.bridge.ReadableType;

import java.util.HashMap;
import java.util.Map;

import javax.annotation.Nullable;


public class NotificareUtils {

    /**
     * Create a Map from ReadableMap
     * @param data
     * @return
     */
    public static Map<String, Object> createMap(@Nullable ReadableMap data) {

        if (data == null) {
            return null;
        }

        Map<String, Object> map = new HashMap<>();
        ReadableMapKeySetIterator iterator = data.keySetIterator();


        while (iterator.hasNextKey()) {
            String key = iterator.nextKey();
            ReadableType readableType = data.getType(key);
            switch (readableType) {
                case Null:
                    map.put(key, null);
                    break;
                case Boolean:
                    map.put(key, data.getBoolean(key));
                    break;
                case Number:
                    map.put(key, data.getDouble(key));
                    break;
                case String:
                    map.put(key, data.getString(key));
                    break;
                case Map:
                    map.put(key, createMap(data.getMap(key)));
                    break;
                default:
                    break;
            }
        }

        return map;
    }
}
