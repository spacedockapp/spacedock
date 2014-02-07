// Generated code, any edits will be eventually lost.
package com.funnyhatsoftware.spacedock.data;

import java.util.ArrayList;
import java.util.Map;

public class ResourceBase extends SetItem {
    String ability;
    public String getAbility() { return ability; }
    public ResourceBase setAbility(String v) { ability = v; return this;}
    int cost;
    public int getCost() { return cost; }
    public ResourceBase setCost(int v) { cost = v; return this;}
    String externalId;
    public String getExternalId() { return externalId; }
    public ResourceBase setExternalId(String v) { externalId = v; return this;}
    String special;
    public String getSpecial() { return special; }
    public ResourceBase setSpecial(String v) { special = v; return this;}
    String title;
    public String getTitle() { return title; }
    public ResourceBase setTitle(String v) { title = v; return this;}
    String type;
    public String getType() { return type; }
    public ResourceBase setType(String v) { type = v; return this;}
    boolean unique;
    public boolean getUnique() { return unique; }
    public ResourceBase setUnique(boolean v) { unique = v; return this;}
    ArrayList<Squad> squad = new ArrayList<Squad>();
    @SuppressWarnings("unchecked")
    public ArrayList<Squad> getSquad() { return (ArrayList<Squad>)squad.clone(); }
    @SuppressWarnings("unchecked")
    public ResourceBase setSquad(ArrayList<Squad> v) { squad = (ArrayList<Squad>)v.clone(); return this;}

    public void update(Map<String,Object> data) {
        super.update(data);
        ability = DataUtils.stringValue((String)data.get("Ability"));
        cost = DataUtils.intValue((String)data.get("Cost"));
        externalId = DataUtils.stringValue((String)data.get("Id"));
        special = DataUtils.stringValue((String)data.get("Special"));
        title = DataUtils.stringValue((String)data.get("Title"));
        type = DataUtils.stringValue((String)data.get("Type"));
        unique = DataUtils.booleanValue((String)data.get("Unique"));
    }

}
