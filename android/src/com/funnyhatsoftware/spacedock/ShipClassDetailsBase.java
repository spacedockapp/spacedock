package com.funnyhatsoftware.spacedock;

import java.util.ArrayList;

class ShipClassDetailsBase {
	String externalId;
	String frontArc;
	String name;
	String rearArc;
	ArrayList<Maneuver> maneuvers = new ArrayList<Maneuver>();
	ArrayList<Ship> ships = new ArrayList<Ship>();
}
