// Generated code, any edits will be eventually lost.
package com.funnyhatsoftware.spacedock.data;

import java.util.Map;

public class ManeuverBase {
    String color;
    public String getColor() { return color; }
    public ManeuverBase setColor(String v) { color = v; return this;}
    String kind;
    public String getKind() { return kind; }
    public ManeuverBase setKind(String v) { kind = v; return this;}
    int speed;
    public int getSpeed() { return speed; }
    public ManeuverBase setSpeed(int v) { speed = v; return this;}
    ShipClassDetails shipClassDetails;
    public ShipClassDetails getShipClassDetails() { return shipClassDetails; }
    public ManeuverBase setShipClassDetails(ShipClassDetails v) { shipClassDetails = v; return this;}

    public void update(Map<String,Object> data) {
        color = DataUtils.stringValue((String)data.get("Color"));
        kind = DataUtils.stringValue((String)data.get("Kind"));
        speed = DataUtils.intValue((String)data.get("Speed"));
    }

}
