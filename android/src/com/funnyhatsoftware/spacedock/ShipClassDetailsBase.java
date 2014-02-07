package com.funnyhatsoftware.spacedock;

import java.util.Map;

import java.util.ArrayList;

public class ShipClassDetailsBase {
	public String externalId;
	public String frontArc;
	public String name;
	public String rearArc;
	public ArrayList<Maneuver> maneuvers = new ArrayList<Maneuver>();
	public ArrayList<Ship> ships = new ArrayList<Ship>();

	public void update(Map<String,Object> data) {
		externalId = Utils.stringValue((String)data.get("Id"));
		frontArc = Utils.stringValue((String)data.get("FrontArc"));
		name = Utils.stringValue((String)data.get("Name"));
		rearArc = Utils.stringValue((String)data.get("RearArc"));
	}

}
