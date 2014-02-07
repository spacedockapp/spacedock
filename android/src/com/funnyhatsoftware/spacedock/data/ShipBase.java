package com.funnyhatsoftware.spacedock.data;

import java.util.ArrayList;
import java.util.Map;

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
        ability = DataUtils.stringValue((String)data.get("Ability"));
        agility = DataUtils.intValue((String)data.get("Agility"));
        attack = DataUtils.intValue((String)data.get("Attack"));
        battleStations = DataUtils.intValue((String)data.get("Battlestations"));
        cloak = DataUtils.intValue((String)data.get("Cloak"));
        cost = DataUtils.intValue((String)data.get("Cost"));
        crew = DataUtils.intValue((String)data.get("Crew"));
        evasiveManeuvers = DataUtils.intValue((String)data.get("EvasiveManeuvers"));
        externalId = DataUtils.stringValue((String)data.get("Id"));
        faction = DataUtils.stringValue((String)data.get("Faction"));
        hull = DataUtils.intValue((String)data.get("Hull"));
        scan = DataUtils.intValue((String)data.get("Scan"));
        sensorEcho = DataUtils.intValue((String)data.get("SensorEcho"));
        shield = DataUtils.intValue((String)data.get("Shield"));
        shipClass = DataUtils.stringValue((String)data.get("ShipClass"));
        targetLock = DataUtils.intValue((String)data.get("TargetLock"));
        tech = DataUtils.intValue((String)data.get("Tech"));
        title = DataUtils.stringValue((String)data.get("Title"));
        unique = DataUtils.booleanValue((String)data.get("Unique"));
        weapon = DataUtils.intValue((String)data.get("Weapon"));
    }

}
