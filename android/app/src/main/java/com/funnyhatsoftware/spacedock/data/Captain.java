
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
        // Defaulting to Federation Captain in case of no faction default
        return Universe.getUniverse().getCaptain("2003");
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
        return ("addonetechslot".equals(mSpecial)
                || "AddsHiddenTechSlot".equals(mSpecial)
                || "calvin_hudson_b_71528".equals(mExternalId)
                || "jean_luc_picard_b_71531".equals(mExternalId)) ? 1 : 0;
    }

    public int additionalCrewSlots() {
        if ("AddTwoCrewSlotsDominionCostBonus".equals(mSpecial)) {
            return 2;
        } else if ("lore_71522".equals(mSpecial)
                || "Add_Crew_1".equals(mSpecial)
                || "calvin_hudson_71528".equals(mExternalId)
                || "jean_luc_picard_d_71531".equals(mExternalId)
                || "chakotay_b_71528".equals(mExternalId)) {
            return 1;
        }
        return super.additionalCrewSlots();
    }

    public int additionalWeaponSlots() {
        if ("calvin_hudson_c_71528".equals(mExternalId)
                || "jean_luc_picard_c_71531".equals(mExternalId)
                || "chakotay_71528".equals(mExternalId)) {
            return 1;
        }
        return 0;
    }

    public int additionalTalentSlots() {
        int talent = getTalent();
        if ("addonetalentslot".equals(mSpecial)) {
            talent++;
        }
        return talent;
    }

    public int additionalBorgSlots() {
        int borg = 0;
        if ("AddOneBorgSlot".equals(mSpecial)) {
            borg++;
        }
        return borg;
    }

    public boolean isKlingon() {
        return getFaction().equals(Constants.KLINGON);
    }

    public boolean isBajoran() {
        return getFaction().equals(Constants.BAJORAN);
    }

    public boolean isDominion() {
        return getFaction().equals(Constants.DOMINION);
    }
    public boolean isFederation() {
        return getFaction().equals(Constants.FEDERATION);
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
