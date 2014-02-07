package com.funnyhatsoftware.spacedock.data;

import java.util.ArrayList;
import java.util.Map;

public class UpgradeBase extends SetItem {
    public String ability;
    public int cost;
    public String externalId;
    public String faction;
    public boolean placeholder;
    public String special;
    public String title;
    public boolean unique;
    public String upType;
    public ArrayList<EquippedUpgrade> equippedUpgrades = new ArrayList<EquippedUpgrade>();

    public void update(Map<String,Object> data) {
        ability = DataUtils.stringValue((String)data.get("Ability"));
        cost = DataUtils.intValue((String)data.get("Cost"));
        externalId = DataUtils.stringValue((String)data.get("Id"));
        faction = DataUtils.stringValue((String)data.get("Faction"));
        placeholder = DataUtils.booleanValue((String)data.get("Placeholder"));
        special = DataUtils.stringValue((String)data.get("Special"));
        title = DataUtils.stringValue((String)data.get("Title"));
        unique = DataUtils.booleanValue((String)data.get("Unique"));
        upType = DataUtils.stringValue((String)data.get("Type"));
    }

}
