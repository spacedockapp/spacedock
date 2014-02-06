package com.funnyhatsoftware.spacedock;

import java.util.ArrayList;

class UpgradeBase extends SetItem {
	String ability;
	int cost;
	String externalId;
	String faction;
	boolean placeholder;
	String special;
	String title;
	boolean unique;
	String upType;
	ArrayList<EquippedUpgrade> equippedUpgrades = new ArrayList<EquippedUpgrade>();
}
