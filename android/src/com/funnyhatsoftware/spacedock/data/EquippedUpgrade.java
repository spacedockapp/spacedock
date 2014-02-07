package com.funnyhatsoftware.spacedock.data;

public class EquippedUpgrade extends EquippedUpgradeBase {

	public int calculateCost() {
		if (overridden) {
			return overriddenCost;
		}
		return upgrade.cost;
	}
}
