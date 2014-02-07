package com.funnyhatsoftware.spacedock.data;

import java.util.Map;

public class ManeuverBase {
    public String color;
    public String kind;
    public int speed;
    public ShipClassDetails shipClassDetails;

    public void update(Map<String,Object> data) {
        color = DataUtils.stringValue((String)data.get("Color"));
        kind = DataUtils.stringValue((String)data.get("Kind"));
        speed = DataUtils.intValue((String)data.get("Speed"));
    }

}
