
package com.funnyhatsoftware.spacedock.data;

import android.annotation.SuppressLint;
import java.io.InputStream;
import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.Date;

public class DataUtils {
    public static int intValue(String v) {
        if (v == null) {
            return 0;
        }
        try {
            return Integer.valueOf(v);
        } catch (Exception e) {
        }
        return 0;
    }

    static double doubleValue(String v) {
        if (v == null) {
            return 0;
        }
        try {
            return Double.valueOf(v);
        } catch (Exception e) {
        }
        return 0;
    }

    static boolean booleanValue(String v) {
        if (v == null) {
            return false;
        }
        return v.equalsIgnoreCase("Y");
    }

    public static String stringValue(String v) {
        if (v == null) {
            return "";
        }
        return v;
    }

    @SuppressLint("SimpleDateFormat")
    static public Date dateValue(String v) {
        if (v == null) {
            return new Date();
        }
        String s = v.replace("Z", "+00:00");
        s = s.substring(0, 22) + s.substring(23); // to get rid of the ":"
        try {
            return new SimpleDateFormat("yyyy-MM-dd'T'HH:mm:ssZ").parse(s);
        } catch (ParseException e) {
            e.printStackTrace();
        }
        return new Date();
    }

    static public int compareInt(int v1, int v2) {
        if (v1 > v2) {
            return 1;
        }

        if (v1 < v2) {
            return -1;
        }

        return 0;
    }

    public static int compareBool(boolean unique, boolean unique2) {
        if (unique == unique2) {
            return 0;
        }
        if (unique && !unique2) {
            return 1;
        }
        return -1;
    }

    public static boolean compareObjects(Object o1, Object o2) {
        if (o1 == null) {
            return o2 == null;
        }

        return o1.equals(o2);
    }

    static public String convertStreamToString(InputStream is) {
        java.util.Scanner s = new java.util.Scanner(is);
        s.useDelimiter("\\A");
        String value = s.hasNext() ? s.next() : "";
        s.close();
        return value;
    }

}
