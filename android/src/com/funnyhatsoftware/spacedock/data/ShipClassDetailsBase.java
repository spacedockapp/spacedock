package com.funnyhatsoftware.spacedock.data;

import java.util.ArrayList;
import java.util.Map;

public class ShipClassDetailsBase {
    public String externalId;
    public String frontArc;
    public String name;
    public String rearArc;
    public ArrayList<Maneuver> maneuvers = new ArrayList<Maneuver>();
    public ArrayList<Ship> ships = new ArrayList<Ship>();

    public void update(Map<String,Object> data) {
        externalId = DataUtils.stringValue((String)data.get("Id"));
        frontArc = DataUtils.stringValue((String)data.get("FrontArc"));
        name = DataUtils.stringValue((String)data.get("Name"));
        rearArc = DataUtils.stringValue((String)data.get("RearArc"));
    }

}
