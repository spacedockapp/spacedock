package com.funnyhatsoftware.spacedock;

import java.util.Map;

import java.util.ArrayList;

public class ResourceBase extends SetItem {
	public String ability;
	public int cost;
	public String externalId;
	public String special;
	public String title;
	public String type;
	public boolean unique;
	public ArrayList<Squad> squad = new ArrayList<Squad>();

	public void update(Map<String,Object> data) {
		ability = Utils.stringValue((String)data.get("Ability"));
		cost = Utils.intValue((String)data.get("Cost"));
		externalId = Utils.stringValue((String)data.get("Id"));
		special = Utils.stringValue((String)data.get("Special"));
		title = Utils.stringValue((String)data.get("Title"));
		type = Utils.stringValue((String)data.get("Type"));
		unique = Utils.booleanValue((String)data.get("Unique"));
	}

}
