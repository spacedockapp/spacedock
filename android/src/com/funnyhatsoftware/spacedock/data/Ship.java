
package com.funnyhatsoftware.spacedock.data;

import java.util.ArrayList;
import java.util.Comparator;

import android.text.TextUtils;

public class Ship extends ShipBase {

    static class ShipComparator implements Comparator<Ship> {
        @Override
        public int compare(Ship o1, Ship o2) {
            int factionCompare = o1.getFaction().compareTo(o2.getFaction());
            if (factionCompare == 0) {
                int classCompare = o1.getShipClass().compareTo(o2.getShipClass());
                if (classCompare == 0) {
                    int uniqueCompare = DataUtils.compareBool(o2.getUnique(), o1.getUnique());
                    if (uniqueCompare == 0) {
                        int titleCompare = o1.getTitle().compareTo(o2.getTitle());
                        return titleCompare;
                    }
                    return uniqueCompare;
                }
                return classCompare;
            }
            return factionCompare;
        }
    }

    public static Ship shipForId(String externalId) {
        return Universe.getUniverse().getShip(externalId);
    }

    public Ship getCounterpart() {
        ArrayList<Ship> ships = Universe.getUniverse().getShips();
        for (Ship ship : ships) {
            if (mShipClass.equals(ship.mShipClass)) {
                if (anySetExternalId().equals(ship.anySetExternalId())) {
                    return ship;
                }
            }
        }
        return null;
    }

    public String formattedClass() {
        return mShipClass;
    }

    private String asDegrees(String textValue) {
        if (textValue.length() == 0) {
            return "";
        }
        return textValue + "¼";
    }

    public String formattedFrontArc() {
        return asDegrees(mShipClassDetails.mFrontArc);
    }

    public String formattedRearArc() {
        return asDegrees(mShipClassDetails.mRearArc);
    }

    public String capabilities() {
        ArrayList<String> caps = new ArrayList<String>();
        int v = getTech();
        if (v > 0) {
            caps.add("Tech: " + Integer.toString(v));

        }

        v = getWeapon();
        if (v > 0) {
            caps.add("Weap: " + Integer.toString(v));

        }

        v = getCrew();
        if (v > 0) {
            caps.add("Crew: " + Integer.toString(v));

        }

        return TextUtils.join(" ", caps);
    }

    public String getPlainDescription() {
        if (!getUnique()) {
            return mShipClass;
        }

        return mTitle;
    }

    public String getDescriptiveTitle() {
        if (getUnique()) {
            return mTitle;
        }

        return mShipClass;
    }

    public String factionCode() {
        return mFaction.substring(0, 1);
    }

    public boolean isBreen() {
        return mShipClass.contains(Constants.BREEN);
    }

    public boolean isJemhadar() {
        return mShipClass.toLowerCase().contains(Constants.JEMHADAR_LC);
    }

    public boolean isKeldon() {
        return mShipClass.contains("Keldon");
    }

    public boolean isRomulanScienceVessel() {
        return mShipClass.equals("Romulan Science Vessel");
    }

    public boolean isDefiant() {
        return mTitle.equals("U.S.S. Defiant");
    }

    public boolean isUnique() {
        return mUnique;
    }

    public boolean isFederation() {
        return mFaction.equals(Constants.FEDERATION);
    }

    public boolean isBajoran() {
        return mFaction.equals(Constants.BAJORAN);
    }

    public boolean isSpecies8472() {
        return mFaction.equals(Constants.SPECIES_8472);
    }

    public boolean isBorg() {
        return mFaction.equals(Constants.BORG);
    }

    public boolean isKazon() {
        return mFaction.equals(Constants.KAZON);
    }

    public boolean isVoyager() {
        return mTitle.equals("U.S.S. Voyager");
    }

    public boolean isFighterSquadron() {
        String shipClass = getShipClass();
        if (shipClass != null) {
            return shipClass.equals(Constants.HIDEKIS) || shipClass.equals(Constants.FED_FIGHTERS);
        }
        return false;
    }

    public ArrayList<String> actionStrings() {
        ArrayList<String> actions = new ArrayList<String>();
        if (mScan > 0) {
            actions.add("Scan");
        }

        if (mCloak > 0) {
            actions.add("Cloak");
        }

        if (mBattleStations > 0) {
            actions.add("Battle");
        }

        if (mEvasiveManeuvers > 0) {
            actions.add("Evasive");
        }

        if (mTargetLock > 0) {
            actions.add("Lock");
        }

        return actions;
    }

    public String movesSummary() {
        if (mShipClassDetails == null) {
            return "";
        }
        return mShipClassDetails.getMovesSummary();
    }

}
