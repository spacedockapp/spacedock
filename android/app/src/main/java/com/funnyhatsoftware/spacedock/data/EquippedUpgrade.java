package com.funnyhatsoftware.spacedock.data;

import org.json.JSONException;
import org.json.JSONObject;

public class EquippedUpgrade extends EquippedUpgradeBase {

    public int calculateCost() {
        return getCost();
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

    public String getExternalId() { return getUpgrade().getExternalId(); }

    String mSpecialTag;

    public String getSpecialTag() { return mSpecialTag; }

    public void setSpecialTag(String specialTag) { mSpecialTag = specialTag; }

    int getBaseCost() {

        if (mUpgrade.isPlaceholder()) {
            return 0;
        }

        return mUpgrade.getCost();
    }

    int getNonOverriddenCost() {
        EquippedShip equippedShip = getEquippedShip();
        if (equippedShip == null) {
            return mUpgrade.getCost();
        }
        return mUpgrade.calculateCostForShip(equippedShip, this);
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

    public boolean isEqualToUpgrade(Upgrade upgrade) {
        if (upgrade.isPlaceholder() != isPlaceholder()) {
            return false;
        }

        return getUpgrade().getExternalId().equals(upgrade.getExternalId());

    }

    public JSONObject asJSON() throws JSONException {
        JSONObject o = new JSONObject();
        Upgrade upgrade = getUpgrade();
        o.put(JSONLabels.JSON_LABEL_UPGRADE_ID, upgrade.getExternalId());
        o.put(JSONLabels.JSON_LABEL_UPGRADE_TITLE, upgrade.getTitle());
        if (getOverridden()) {
            o.put(JSONLabels.JSON_LABEL_COST_IS_OVERRIDDEN, true);
            o.put(JSONLabels.JSON_LABEL_OVERRIDDEN_COST, getOverriddenCost());
        }
        if (getSpecialTag() != null && getSpecialTag().length() > 0) {
            o.put(JSONLabels.JSON_LABEL_SPECIALTAG,getSpecialTag());
        }
        return o;
    }

}
