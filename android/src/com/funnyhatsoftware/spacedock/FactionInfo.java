package com.funnyhatsoftware.spacedock;

import android.content.res.Resources;
import android.graphics.Color;
import android.support.v4.util.ArrayMap;
import android.text.Spannable;
import android.text.SpannableString;
import android.text.SpannableStringBuilder;
import android.text.style.ForegroundColorSpan;
import android.util.Log;

import java.util.HashSet;

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

    public static Spannable buildSummarySpannable(Resources res, HashSet<String> factions) {
        String string = "";
        for (String faction : factions) {
            if (faction == null) continue;
            string += faction.charAt(0);
        }
        Spannable spannable = new SpannableString(string);
        int index = 0;
        for (String faction : factions) {
            if (faction == null) continue;
            ForegroundColorSpan span = new ForegroundColorSpan(getFactionColor(res, faction));
            spannable.setSpan(span, index, index+1, 0);
            index++;
        }
        return null;
    }
}
