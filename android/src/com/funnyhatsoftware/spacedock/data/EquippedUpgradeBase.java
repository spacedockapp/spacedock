// Generated code, any edits will be eventually lost.
package com.funnyhatsoftware.spacedock.data;

import java.util.Map;

public class EquippedUpgradeBase extends Base {
    boolean mOverridden;
    public boolean getOverridden() { return mOverridden; }
    public EquippedUpgradeBase setOverridden(boolean v) { mOverridden = v; return this;}
    int mOverriddenCost;
    public int getOverriddenCost() { return mOverriddenCost; }
    public EquippedUpgradeBase setOverriddenCost(int v) { mOverriddenCost = v; return this;}
    EquippedShip mEquippedShip;
    public EquippedShip getEquippedShip() { return mEquippedShip; }
    public EquippedUpgradeBase setEquippedShip(EquippedShip v) { mEquippedShip = v; return this;}
    Upgrade mUpgrade;
    public Upgrade getUpgrade() { return mUpgrade; }
    public EquippedUpgradeBase setUpgrade(Upgrade v) { mUpgrade = v; return this;}

    public void update(Map<String,Object> data) {
        mOverridden = DataUtils.booleanValue((String)data.get("Overridden"));
        mOverriddenCost = DataUtils.intValue((String)data.get("OverriddenCost"));
    }

}
