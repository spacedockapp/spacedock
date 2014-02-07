package com.funnyhatsoftware.spacedock.data;

import java.util.ArrayList;
import java.util.Map;

public class ResourceBase extends SetItem {
    public String ability;
    public int cost;
    public String externalId;
    public String special;
    public String title;
    public String type;
    public boolean unique;
    public ArrayList<Squad> squad = new ArrayList<Squad>();

    public void update(Map<String,Object> data) {
        ability = DataUtils.stringValue((String)data.get("Ability"));
        cost = DataUtils.intValue((String)data.get("Cost"));
        externalId = DataUtils.stringValue((String)data.get("Id"));
        special = DataUtils.stringValue((String)data.get("Special"));
        title = DataUtils.stringValue((String)data.get("Title"));
        type = DataUtils.stringValue((String)data.get("Type"));
        unique = DataUtils.booleanValue((String)data.get("Unique"));
    }

}
