package com.funnyhatsoftware.spacedock;

import java.util.Map;

public class ManeuverBase {
	public String color;
	public String kind;
	public int speed;
	public ShipClassDetails shipClassDetails;

	public void update(Map<String,Object> data) {
		color = Utils.stringValue((String)data.get("Color"));
		kind = Utils.stringValue((String)data.get("Kind"));
		speed = Utils.intValue((String)data.get("Speed"));
	}

}
