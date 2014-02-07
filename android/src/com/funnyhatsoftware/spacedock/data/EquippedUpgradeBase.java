package com.funnyhatsoftware.spacedock.data;

import java.util.Map;

public class EquippedUpgradeBase {
    public boolean overridden;
    public int overriddenCost;
    public EquippedShip equippedShip;
    public Upgrade upgrade;

    public void update(Map<String,Object> data) {
        overridden = DataUtils.booleanValue((String)data.get("Overridden"));
        overriddenCost = DataUtils.intValue((String)data.get("OverriddenCost"));
    }

}
