
package com.funnyhatsoftware.spacedock.data;

import java.util.ArrayList;
import java.util.Comparator;

import android.text.TextUtils;

public class Flagship extends FlagshipBase {

    static class FlagshipComparator implements Comparator<Flagship> {
        @Override
        public int compare(Flagship o1, Flagship o2) {
            int factionCompare = o1.getFaction().compareTo(o2.getFaction());
            if (factionCompare == 0) {
                int titleCompare = o1.getTitle().compareTo(o2.getTitle());
                return titleCompare;
            }
            return factionCompare;
        }
    }

    String getName()
    {
        if (mFaction.equals("Independent")) {
            return mTitle;
        }
        return mFaction;
    }

    String getPlainDescription() {
        return "Flagship: " + mTitle;
    }

    boolean compatibleWithShip(Ship targetShip)
    {
        if (mFaction.equals("Independent")) {
            return true;
        }

        return mFaction.equals(targetShip.getFaction());
    }

    private static void addCap(ArrayList<String> caps, String label, int value) {
        if (value > 0) {
            String s = String.format("%s: %d", label, value);
            caps.add(s);
        }
    }

    public String getCapabilities() {
        ArrayList<String> caps = new ArrayList<String>();
        addCap(caps, "Tech", getTech());
        addCap(caps, "Weap", getWeapon());
        addCap(caps, "Crew", getCrew());
        addCap(caps, "Tale", getTalent());
        addCap(caps, "Echo", getSensorEcho());
        addCap(caps, "EvaM", getEvasiveManeuvers());
        addCap(caps, "Scan", getScan());
        addCap(caps, "Lock", getTargetLock());
        addCap(caps, "BatS", getBattleStations());
        addCap(caps, "Clk", getCloak());
        return TextUtils.join(",  ", caps);
    }

}
