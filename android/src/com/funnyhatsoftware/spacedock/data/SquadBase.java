// Generated code, any edits will be eventually lost.
package com.funnyhatsoftware.spacedock.data;

import java.util.ArrayList;
import java.util.Map;

public class SquadBase {
    int additionalPoints;
    public int getAdditionalPoints() { return additionalPoints; }
    public SquadBase setAdditionalPoints(int v) { additionalPoints = v; return this;}
    String name;
    public String getName() { return name; }
    public SquadBase setName(String v) { name = v; return this;}
    String notes;
    public String getNotes() { return notes; }
    public SquadBase setNotes(String v) { notes = v; return this;}
    Resource resource;
    public Resource getResource() { return resource; }
    public SquadBase setResource(Resource v) { resource = v; return this;}
    ArrayList<EquippedShip> equippedShips = new ArrayList<EquippedShip>();
    @SuppressWarnings("unchecked")
    public ArrayList<EquippedShip> getEquippedShips() { return (ArrayList<EquippedShip>)equippedShips.clone(); }
    @SuppressWarnings("unchecked")
    public SquadBase setEquippedShips(ArrayList<EquippedShip> v) { equippedShips = (ArrayList<EquippedShip>)v.clone(); return this;}

    public void update(Map<String,Object> data) {
        additionalPoints = DataUtils.intValue((String)data.get("AdditionalPoints"));
        name = DataUtils.stringValue((String)data.get("Name"));
        notes = DataUtils.stringValue((String)data.get("Notes"));
    }

}
