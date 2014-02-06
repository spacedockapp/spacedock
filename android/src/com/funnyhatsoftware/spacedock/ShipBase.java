package com.funnyhatsoftware.spacedock;

import java.util.ArrayList;

class ShipBase extends SetItem {
	String ability;
	int agility;
	int attack;
	int battleStations;
	int cloak;
	int cost;
	int crew;
	int evasiveManeuvers;
	String externalId;
	String faction;
	int hull;
	int scan;
	int sensorEcho;
	int shield;
	String shipClass;
	int targetLock;
	int tech;
	String title;
	boolean unique;
	int weapon;
	ShipClassDetails shipClassDetails;
	ArrayList<EquippedShip> equippedShips = new ArrayList<EquippedShip>();
}
