// Generated code, any edits will be eventually lost.
package com.funnyhatsoftware.spacedock.data;

import java.util.Map;

public class EquippedUpgradeBase {
    boolean overridden;
    public boolean getOverridden() { return overridden; }
    public EquippedUpgradeBase setOverridden(boolean v) { overridden = v; return this;}
    int overriddenCost;
    public int getOverriddenCost() { return overriddenCost; }
    public EquippedUpgradeBase setOverriddenCost(int v) { overriddenCost = v; return this;}
    EquippedShip equippedShip;
    public EquippedShip getEquippedShip() { return equippedShip; }
    public EquippedUpgradeBase setEquippedShip(EquippedShip v) { equippedShip = v; return this;}
    Upgrade upgrade;
    public Upgrade getUpgrade() { return upgrade; }
    public EquippedUpgradeBase setUpgrade(Upgrade v) { upgrade = v; return this;}

    public void update(Map<String,Object> data) {
        overridden = DataUtils.booleanValue((String)data.get("Overridden"));
        overriddenCost = DataUtils.intValue((String)data.get("OverriddenCost"));
    }

}
