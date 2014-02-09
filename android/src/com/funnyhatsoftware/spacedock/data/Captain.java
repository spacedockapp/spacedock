
package com.funnyhatsoftware.spacedock.data;

public class Captain extends CaptainBase {
    public Upgrade zeroCostCaptain(String faction) {
        return null;
    }

    public Upgrade captainForId(String externalId) {
        return Universe.getUniverse().getCaptain(externalId);
    }

    public boolean isZeroCost() {
        return mCost == 0;
    }

    public int additionalTechSlots() {
        return mSpecial.equals("addonetechslot") ? 1 : 0;
    }

    public int additionalCrewSlots() {
        return mSpecial.equals("AddTwoCrewSlotsDominionCostBonus") ? 2 : 0;
    }
}
