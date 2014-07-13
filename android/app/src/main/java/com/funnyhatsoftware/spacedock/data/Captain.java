
package com.funnyhatsoftware.spacedock.data;

import java.util.ArrayList;
import java.util.Comparator;

import android.annotation.SuppressLint;

public class Captain extends CaptainBase {
    static class CaptainComparator implements Comparator<Captain> {
        int compareZeroCost(Captain o1, Captain o2) {
            if (o1.isZeroCost() == o2.isZeroCost())
                return 0;
            return o1.isZeroCost() ? -1 : 1;
        }

        @Override
        public int compare(Captain o1, Captain o2) {
            int factionCompare = o1.getFaction().compareTo(o2.getFaction());
            if (factionCompare == 0) {
                int zeroCostCaptainCompare = compareZeroCost(o1, o2);
                if (zeroCostCaptainCompare == 0) {
                    int titleCompare = o1.getTitle().compareTo(o2.getTitle());
                    if (titleCompare == 0) {
                        return DataUtils.compareInt(o2.getCost(), o1.getCost());
                    }
                    return titleCompare;
                }
                return zeroCostCaptainCompare;
            }
            return factionCompare;
        }
    }

    public static Upgrade zeroCostCaptain(String faction) {
        for (Captain captain : Universe.getUniverse().captains.values()) {
            if (captain.getFaction().equals(faction) && captain.isZeroCost()) {
                return captain;
            }
        }
        throw new IllegalStateException("No zero cost captain exists for faction " + faction);
    }

    public static Upgrade zeroCostCaptainForShip(Ship targetShip) {
        if (targetShip == null) {
            return zeroCostCaptain("Federation");
        }
        ArrayList<Set> targetShipSets = targetShip.getSets();
        String targetFaction = targetShip.getFaction();
        for (Captain captain : Universe.getUniverse().captains.values()) {
            if (captain.isZeroCost() && targetFaction.equals(captain.getFaction())) {
                for (Set set : targetShipSets) {
                    if (captain.isInSet(set)) {
                        return captain;
                    }
                }
            }
        }
        return zeroCostCaptain(targetShip.getFaction());
    }

    public Upgrade captainForId(String externalId) {
        return Universe.getUniverse().getCaptain(externalId);
    }

    public boolean isZeroCost() {
        return mCost == 0;
    }

    public int additionalTechSlots() {
        return ("addonetechslot".equals(mSpecial) || "AddsHiddenTechSlot".equals(mSpecial)) ? 1 : 0;
    }

    public int additionalCrewSlots() {
        if ("AddTwoCrewSlotsDominionCostBonus".equals(mSpecial)) {
            return 2;
        }
        return super.additionalCrewSlots();
    }

    public boolean isKlingon() {
        return getFaction().equals(Constants.KLINGON);
    }

    public boolean isBajoran() {
        return getFaction().equals(Constants.BAJORAN);
    }

    public boolean isTholian() {
        String externalId = getExternalId();
        return externalId.equals(Constants.LOSKENE)
                || externalId.equals(Constants.ZERO_COST_THOLIAN_CAPTAIN);
    }

    @SuppressLint("DefaultLocale")
    public String toString() {
        return String.format("%s-%d (%d)", getTitle(), getSkill(), getCost());
    }

}
