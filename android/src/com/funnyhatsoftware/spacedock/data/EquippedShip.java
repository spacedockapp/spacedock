
package com.funnyhatsoftware.spacedock.data;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

public class EquippedShip extends EquippedShipBase {

    public EquippedShip() {
    }

    public EquippedShip(Ship inShip) {
        mShip = inShip;
    }

    public boolean getIsResourceSideboard() {
        return getShip() == null;
    }

    public void importUpgrades(Universe universe, JSONObject shipData)
            throws JSONException {
        JSONObject captainObject = shipData.optJSONObject("captain");
        String captainId = captainObject.optString("upgradeId");
        Captain captain = universe.getCaptain(captainId);
        addUpgrade(captain);
        JSONArray upgrades = shipData.getJSONArray("upgrades");
        for (int i = 0; i < upgrades.length(); ++i) {
            JSONObject upgradeData = upgrades.getJSONObject(i);
            String upgradeId = upgradeData.optString("upgradeId");
            Upgrade upgrade = universe.getUpgrade(upgradeId);
            EquippedUpgrade eu = addUpgrade(upgrade);
            if (upgradeData.optBoolean("costIsOverridden")) {
                eu.setOverridden(true);
                eu.setOverriddenCost(upgradeData.optInt("overriddenCost"));
            }
        }
    }

    public EquippedUpgrade addUpgrade(Upgrade upgrade) {
        EquippedUpgrade eu = new EquippedUpgrade();
        eu.setUpgrade(upgrade);
        mUpgrades.add(eu);
        return eu;
    }

    public void removeUpgrade(EquippedUpgrade eu) {
        mUpgrades.remove(eu);
    }

    public int calculateCost() {
        int cost = mShip.getCost();
        for (EquippedUpgrade eu : mUpgrades) {
            cost += eu.calculateCost();
        }
        return cost;
    }

}
