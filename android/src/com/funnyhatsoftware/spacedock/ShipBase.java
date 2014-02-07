package com.funnyhatsoftware.spacedock;

import java.util.Map;

import java.util.ArrayList;

public class ShipBase extends SetItem {
	public String ability;
	public int agility;
	public int attack;
	public int battleStations;
	public int cloak;
	public int cost;
	public int crew;
	public int evasiveManeuvers;
	public String externalId;
	public String faction;
	public int hull;
	public int scan;
	public int sensorEcho;
	public int shield;
	public String shipClass;
	public int targetLock;
	public int tech;
	public String title;
	public boolean unique;
	public int weapon;
	public ShipClassDetails shipClassDetails;
	public ArrayList<EquippedShip> equippedShips = new ArrayList<EquippedShip>();

	public void update(Map<String,Object> data) {
		ability = Utils.stringValue((String)data.get("Ability"));
		agility = Utils.intValue((String)data.get("Agility"));
		attack = Utils.intValue((String)data.get("Attack"));
		battleStations = Utils.intValue((String)data.get("Battlestations"));
		cloak = Utils.intValue((String)data.get("Cloak"));
		cost = Utils.intValue((String)data.get("Cost"));
		crew = Utils.intValue((String)data.get("Crew"));
		evasiveManeuvers = Utils.intValue((String)data.get("EvasiveManeuvers"));
		externalId = Utils.stringValue((String)data.get("Id"));
		faction = Utils.stringValue((String)data.get("Faction"));
		hull = Utils.intValue((String)data.get("Hull"));
		scan = Utils.intValue((String)data.get("Scan"));
		sensorEcho = Utils.intValue((String)data.get("SensorEcho"));
		shield = Utils.intValue((String)data.get("Shield"));
		shipClass = Utils.stringValue((String)data.get("ShipClass"));
		targetLock = Utils.intValue((String)data.get("TargetLock"));
		tech = Utils.intValue((String)data.get("Tech"));
		title = Utils.stringValue((String)data.get("Title"));
		unique = Utils.booleanValue((String)data.get("Unique"));
		weapon = Utils.intValue((String)data.get("Weapon"));
	}

}
