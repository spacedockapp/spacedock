// Generated code, any edits will be eventually lost.
package com.funnyhatsoftware.spacedock.data;

import java.util.ArrayList;
import java.util.Map;

public class ShipBase extends SetItem {
    String ability;
    public String getAbility() { return ability; }
    public ShipBase setAbility(String v) { ability = v; return this;}
    int agility;
    public int getAgility() { return agility; }
    public ShipBase setAgility(int v) { agility = v; return this;}
    int attack;
    public int getAttack() { return attack; }
    public ShipBase setAttack(int v) { attack = v; return this;}
    int battleStations;
    public int getBattleStations() { return battleStations; }
    public ShipBase setBattleStations(int v) { battleStations = v; return this;}
    int cloak;
    public int getCloak() { return cloak; }
    public ShipBase setCloak(int v) { cloak = v; return this;}
    int cost;
    public int getCost() { return cost; }
    public ShipBase setCost(int v) { cost = v; return this;}
    int crew;
    public int getCrew() { return crew; }
    public ShipBase setCrew(int v) { crew = v; return this;}
    int evasiveManeuvers;
    public int getEvasiveManeuvers() { return evasiveManeuvers; }
    public ShipBase setEvasiveManeuvers(int v) { evasiveManeuvers = v; return this;}
    String externalId;
    public String getExternalId() { return externalId; }
    public ShipBase setExternalId(String v) { externalId = v; return this;}
    String faction;
    public String getFaction() { return faction; }
    public ShipBase setFaction(String v) { faction = v; return this;}
    int hull;
    public int getHull() { return hull; }
    public ShipBase setHull(int v) { hull = v; return this;}
    int scan;
    public int getScan() { return scan; }
    public ShipBase setScan(int v) { scan = v; return this;}
    int sensorEcho;
    public int getSensorEcho() { return sensorEcho; }
    public ShipBase setSensorEcho(int v) { sensorEcho = v; return this;}
    int shield;
    public int getShield() { return shield; }
    public ShipBase setShield(int v) { shield = v; return this;}
    String shipClass;
    public String getShipClass() { return shipClass; }
    public ShipBase setShipClass(String v) { shipClass = v; return this;}
    int targetLock;
    public int getTargetLock() { return targetLock; }
    public ShipBase setTargetLock(int v) { targetLock = v; return this;}
    int tech;
    public int getTech() { return tech; }
    public ShipBase setTech(int v) { tech = v; return this;}
    String title;
    public String getTitle() { return title; }
    public ShipBase setTitle(String v) { title = v; return this;}
    boolean unique;
    public boolean getUnique() { return unique; }
    public ShipBase setUnique(boolean v) { unique = v; return this;}
    int weapon;
    public int getWeapon() { return weapon; }
    public ShipBase setWeapon(int v) { weapon = v; return this;}
    ShipClassDetails shipClassDetails;
    public ShipClassDetails getShipClassDetails() { return shipClassDetails; }
    public ShipBase setShipClassDetails(ShipClassDetails v) { shipClassDetails = v; return this;}
    ArrayList<EquippedShip> equippedShips = new ArrayList<EquippedShip>();
    @SuppressWarnings("unchecked")
    public ArrayList<EquippedShip> getEquippedShips() { return (ArrayList<EquippedShip>)equippedShips.clone(); }
    @SuppressWarnings("unchecked")
    public ShipBase setEquippedShips(ArrayList<EquippedShip> v) { equippedShips = (ArrayList<EquippedShip>)v.clone(); return this;}

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
