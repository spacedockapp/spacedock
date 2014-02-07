// Generated code, any edits will be eventually lost.
package com.funnyhatsoftware.spacedock.data;

import java.util.ArrayList;
import java.util.Map;

public class ShipClassDetailsBase {
    String externalId;
    public String getExternalId() { return externalId; }
    public ShipClassDetailsBase setExternalId(String v) { externalId = v; return this;}
    String frontArc;
    public String getFrontArc() { return frontArc; }
    public ShipClassDetailsBase setFrontArc(String v) { frontArc = v; return this;}
    String name;
    public String getName() { return name; }
    public ShipClassDetailsBase setName(String v) { name = v; return this;}
    String rearArc;
    public String getRearArc() { return rearArc; }
    public ShipClassDetailsBase setRearArc(String v) { rearArc = v; return this;}
    ArrayList<Maneuver> maneuvers = new ArrayList<Maneuver>();
    @SuppressWarnings("unchecked")
    public ArrayList<Maneuver> getManeuvers() { return (ArrayList<Maneuver>)maneuvers.clone(); }
    @SuppressWarnings("unchecked")
    public ShipClassDetailsBase setManeuvers(ArrayList<Maneuver> v) { maneuvers = (ArrayList<Maneuver>)v.clone(); return this;}
    ArrayList<Ship> ships = new ArrayList<Ship>();
    @SuppressWarnings("unchecked")
    public ArrayList<Ship> getShips() { return (ArrayList<Ship>)ships.clone(); }
    @SuppressWarnings("unchecked")
    public ShipClassDetailsBase setShips(ArrayList<Ship> v) { ships = (ArrayList<Ship>)v.clone(); return this;}

    public void update(Map<String,Object> data) {
        externalId = DataUtils.stringValue((String)data.get("Id"));
        frontArc = DataUtils.stringValue((String)data.get("FrontArc"));
        name = DataUtils.stringValue((String)data.get("Name"));
        rearArc = DataUtils.stringValue((String)data.get("RearArc"));
    }

}
