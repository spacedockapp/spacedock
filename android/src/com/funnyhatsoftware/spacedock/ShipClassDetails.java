package com.funnyhatsoftware.spacedock;

import java.util.ArrayList;

class ShipClassDetails {
	String externalId;
	String frontArc;
	String name;
	String rearArc;
	ArrayList<Maneuver> maneuvers = new ArrayList<Maneuver>();
	ArrayList<Ship> ships = new ArrayList<Ship>();
}
