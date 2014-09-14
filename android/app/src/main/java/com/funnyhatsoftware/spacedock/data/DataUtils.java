
package com.funnyhatsoftware.spacedock.data;

import android.annotation.SuppressLint;
import java.io.InputStream;
import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.Date;

public class DataUtils {
    public static int intValue(String v, int defaultValue) {
        if (v == null) {
            return defaultValue;
        }
        try {
            return Integer.valueOf(v);
        } catch (Exception e) {
        }
        return defaultValue;
    }

    public static int intValue(String v) {
        return intValue(v, 0);
    }

    static double doubleValue(String v, double defaultValue) {
        if (v == null) {
            return defaultValue;
        }
        try {
            return Double.valueOf(v);
        } catch (Exception e) {
        }
        return defaultValue;
    }

    static double doubleValue(String v) {
        return doubleValue(v, 0);
    }

    static boolean booleanValue(String v, boolean defaultValue) {
        if (v == null) {
            return defaultValue;
        }
        return v.equalsIgnoreCase("Y");
    }

    static boolean booleanValue(String v) {
        return booleanValue(v, false);
    }

    public static String stringValue(String v, String defaultValue) {
        if (v == null) {
            return defaultValue;
        }
        return v;
    }

    public static String stringValue(String v) {
        return stringValue(v, "");
    }

    @SuppressLint("SimpleDateFormat")
    static public Date dateValue(String v, Date defaultValue) {
        if (v == null) {
            return defaultValue;
        }
        if (!v.contains("T")) {
            try {
                return new SimpleDateFormat("yyyy-MM-dd").parse(v);
            } catch (ParseException e) {
                e.printStackTrace();
            }
            return defaultValue;
        }
        try {
            String s = v.replace("Z", "+00:00");
            s = s.substring(0, 22) + s.substring(23); // to get rid of the ":"
            return new SimpleDateFormat("yyyy-MM-dd'T'HH:mm:ssZ").parse(s);
        } catch (ParseException e) {
            e.printStackTrace();
        }
        return defaultValue;
    }

    static public Date dateValue(String v) {
        return dateValue(v, new Date());
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

    public static boolean targetHasFaction(String faction, Factioned target) {
        if (faction == null || faction == "") {
            return false;
        }
        String mainFaction = target.getFaction();
        if (mainFaction == null) {
            mainFaction = "#";
        }
        String additionalFaction = target.getAdditionalFaction();
        if (additionalFaction == null) {
            additionalFaction = "#";
        }
        return faction.equals(mainFaction) || faction.equals(additionalFaction);
    }

    public static boolean factionsMatch(Factioned a, Factioned b) {
        if (targetHasFaction(a.getFaction(), b)) {
            return true;
        }

        return targetHasFaction(a.getAdditionalFaction(), b);

    }

}
