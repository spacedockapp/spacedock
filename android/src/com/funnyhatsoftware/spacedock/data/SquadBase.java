package com.funnyhatsoftware.spacedock.data;

import java.util.ArrayList;
import java.util.Map;

public class SquadBase {
    public int additionalPoints;
    public String name;
    public String notes;
    public Resource resource;
    public ArrayList<EquippedShip> equippedShips = new ArrayList<EquippedShip>();

    public void update(Map<String,Object> data) {
        additionalPoints = DataUtils.intValue((String)data.get("AdditionalPoints"));
        name = DataUtils.stringValue((String)data.get("Name"));
        notes = DataUtils.stringValue((String)data.get("Notes"));
    }

}
