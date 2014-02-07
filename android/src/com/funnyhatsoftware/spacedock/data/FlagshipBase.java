package com.funnyhatsoftware.spacedock.data;

import java.util.ArrayList;
import java.util.Map;

public class FlagshipBase extends SetItem {
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
    public int talent;
    public int targetLock;
    public int tech;
    public String title;
    public int weapon;
    public ArrayList<EquippedShip> ships = new ArrayList<EquippedShip>();

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
        talent = DataUtils.intValue((String)data.get("Talent"));
        targetLock = DataUtils.intValue((String)data.get("TargetLock"));
        tech = DataUtils.intValue((String)data.get("Tech"));
        title = DataUtils.stringValue((String)data.get("Title"));
        weapon = DataUtils.intValue((String)data.get("Weapon"));
    }

}
