
package com.funnyhatsoftware.spacedock.data;

public class DataUtils {
    static int intValue(String v) {
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
}
