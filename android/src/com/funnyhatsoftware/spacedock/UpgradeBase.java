package com.funnyhatsoftware.spacedock;

import java.util.Map;

import java.util.ArrayList;

public class UpgradeBase extends SetItem {
	public String ability;
	public int cost;
	public String externalId;
	public String faction;
	public boolean placeholder;
	public String special;
	public String title;
	public boolean unique;
	public String upType;
	public ArrayList<EquippedUpgrade> equippedUpgrades = new ArrayList<EquippedUpgrade>();

	public void update(Map<String,Object> data) {
		ability = Utils.stringValue((String)data.get("Ability"));
		cost = Utils.intValue((String)data.get("Cost"));
		externalId = Utils.stringValue((String)data.get("Id"));
		faction = Utils.stringValue((String)data.get("Faction"));
		placeholder = Utils.booleanValue((String)data.get("Placeholder"));
		special = Utils.stringValue((String)data.get("Special"));
		title = Utils.stringValue((String)data.get("Title"));
		unique = Utils.booleanValue((String)data.get("Unique"));
		upType = Utils.stringValue((String)data.get("Type"));
	}

}
