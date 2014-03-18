
package com.funnyhatsoftware.spacedock.data;

import org.json.JSONException;
import org.json.JSONObject;

public class EquippedUpgrade extends EquippedUpgradeBase {

    static final String JSON_LABEL_UPGRADE_ID = "upgradeId";
    static final String JSON_LABEL_UPGRADE_TITLE = "upgradeTitle";
    static final String JSON_LABEL_COST_IS_OVERRIDDEN = "costIsOverridden";
    static final String JSON_LABEL_OVERRIDDEN_COST = "overriddenCost";

    public int calculateCost() {
        if (mOverridden) {
            return mOverriddenCost;
        }
        return mUpgrade.mCost;
    }

    public int compareTo(EquippedUpgrade arg1) {
        return getUpgrade().compareTo(arg1.getUpgrade());
    }

    String getTitle() {
        return getUpgrade().getTitle();
    }

    String getFaction() {
        return getUpgrade().getFaction();
    }

    boolean isPlaceholder() {
        return getUpgrade().isPlaceholder();
    }

    String getPlainDescription() {
        return getUpgrade().getPlainDescription();
    }

    int getBaseCost() {

        if (mUpgrade.isPlaceholder()) {
            return 0;
        }

        return mUpgrade.getCost();
    }

    int getNonOverriddenCost() {
        EquippedShip equippedShip = getEquippedShip();
        return mUpgrade.calculateCostForShip(equippedShip);
    }

    int getCost() {
        if (mOverridden) {
            return mOverriddenCost;
        }

        return getNonOverriddenCost();
    }

    int getRawCost() {
        return mUpgrade.getCost();
    }

    public boolean isCaptain() {
        return mUpgrade.isCaptain();
    }

    public JSONObject asJSON() throws JSONException {
        JSONObject o = new JSONObject();
        Upgrade upgrade = getUpgrade();
        o.put(JSON_LABEL_UPGRADE_ID, upgrade.getExternalId());
        o.put(JSON_LABEL_UPGRADE_TITLE, upgrade.getTitle());
        if (getOverridden()) {
            o.put(JSON_LABEL_COST_IS_OVERRIDDEN, true);
            o.put(JSON_LABEL_OVERRIDDEN_COST, getOverriddenCost());
        }
        return o;
    }

}
