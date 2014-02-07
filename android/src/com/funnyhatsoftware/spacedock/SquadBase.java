package com.funnyhatsoftware.spacedock;

import java.util.Map;

import java.util.ArrayList;

public class SquadBase {
	public int additionalPoints;
	public String name;
	public String notes;
	public Resource resource;
	public ArrayList<EquippedShip> equippedShips = new ArrayList<EquippedShip>();

	public void update(Map<String,Object> data) {
		additionalPoints = Utils.intValue((String)data.get("AdditionalPoints"));
		name = Utils.stringValue((String)data.get("Name"));
		notes = Utils.stringValue((String)data.get("Notes"));
	}

}
