package com.funnyhatsoftware.spacedock;

import java.util.Map;

public class EquippedUpgradeBase {
	public boolean overridden;
	public int overriddenCost;
	public EquippedShip equippedShip;
	public Upgrade upgrade;

	public void update(Map<String,Object> data) {
		overridden = Utils.booleanValue((String)data.get("Overridden"));
		overriddenCost = Utils.intValue((String)data.get("OverriddenCost"));
	}

}
