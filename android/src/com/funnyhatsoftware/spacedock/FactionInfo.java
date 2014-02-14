package com.funnyhatsoftware.spacedock;

import android.content.res.Resources;
import android.graphics.Color;
import android.support.v4.util.ArrayMap;

public class FactionInfo {
    private static final ArrayMap<String, Integer> sMap = new ArrayMap<String, Integer>();
    static {
        sMap.put("Federation", R.color.dark_blue);
        sMap.put("Klingon", R.color.dark_red);
        sMap.put("Romulan", R.color.dark_green);
        sMap.put("Dominion", R.color.dark_purple);
    }

    public static int getFactionColor(Resources res, String faction) {
        Integer color = sMap.get(faction);
        if (color == null) {
            return Color.BLACK;
        }
        return res.getColor(color);
    }
}
