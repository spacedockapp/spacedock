package com.funnyhatsoftware.spacedock.data;

import android.text.TextUtils;

import java.util.ArrayList;
import java.util.Comparator;

public class FleetCaptain extends FleetCaptainBase {

    static class FleetCaptainComparator implements Comparator<FleetCaptain> {
        @Override
        public int compare(FleetCaptain o1, FleetCaptain o2) {
            int factionCompare = o1.getFaction().compareTo(o2.getFaction());
            if (factionCompare == 0) {
                int titleCompare = o1.getTitle().compareTo(o2.getTitle());
                return titleCompare;
            }
            return factionCompare;
        }
    }

    String getName() {
        if (mFaction.equals("Independent")) {
            return mTitle;
        }
        return mFaction;
    }

    private boolean mIsPlaceholder = false;
    @Override
    public boolean isPlaceholder() {
        return mIsPlaceholder;
    }
    /*package*/ void setIsPlaceholder(boolean isPlaceholder) {
        mIsPlaceholder = isPlaceholder;
    }

    @Override
    public int getCost() { return 5; } // TODO: make this more elegant

    @Override
    public int calculateCostForShip(EquippedShip equippedShip, EquippedUpgrade equippedUpgrade) {
        return 5;
    }

    public String getPlainDescription() {
        return "FleetCaptain: " + mTitle;
    }

    public boolean compatibleWithFaction(String faction) {
        if (mFaction.equals("Independent")) {
            return true;
        }

        return mFaction.equals(faction);
    }

    public boolean compatibleWithShip(Ship targetShip) {
        return compatibleWithFaction(targetShip.getFaction());
    }

    private static void addCap(ArrayList<String> caps, String label, int value) {
        if (value > 0) {
            String s = String.format("%s: %d", label, value);
            caps.add(s);
        }
    }

    public String getCapabilities() {
        ArrayList<String> caps = new ArrayList<String>();
        addCap(caps, "Tech", getTechAdd());
        addCap(caps, "Weap", getWeaponAdd());
        addCap(caps, "Crew", getCrewAdd());
        addCap(caps, "Tale", getTalentAdd());
        addCap(caps, "CpSk", getCaptainSkillBonus());
        return TextUtils.join(",  ", caps);
    }

}
