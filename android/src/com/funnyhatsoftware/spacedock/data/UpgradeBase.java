// Generated code, any edits will be eventually lost.
package com.funnyhatsoftware.spacedock.data;

import java.util.ArrayList;
import java.util.Map;

public class UpgradeBase extends SetItem {
    String ability;
    public String getAbility() { return ability; }
    public UpgradeBase setAbility(String v) { ability = v; return this;}
    int cost;
    public int getCost() { return cost; }
    public UpgradeBase setCost(int v) { cost = v; return this;}
    String externalId;
    public String getExternalId() { return externalId; }
    public UpgradeBase setExternalId(String v) { externalId = v; return this;}
    String faction;
    public String getFaction() { return faction; }
    public UpgradeBase setFaction(String v) { faction = v; return this;}
    boolean placeholder;
    public boolean getPlaceholder() { return placeholder; }
    public UpgradeBase setPlaceholder(boolean v) { placeholder = v; return this;}
    String special;
    public String getSpecial() { return special; }
    public UpgradeBase setSpecial(String v) { special = v; return this;}
    String title;
    public String getTitle() { return title; }
    public UpgradeBase setTitle(String v) { title = v; return this;}
    boolean unique;
    public boolean getUnique() { return unique; }
    public UpgradeBase setUnique(boolean v) { unique = v; return this;}
    String upType;
    public String getUpType() { return upType; }
    public UpgradeBase setUpType(String v) { upType = v; return this;}
    ArrayList<EquippedUpgrade> equippedUpgrades = new ArrayList<EquippedUpgrade>();
    @SuppressWarnings("unchecked")
    public ArrayList<EquippedUpgrade> getEquippedUpgrades() { return (ArrayList<EquippedUpgrade>)equippedUpgrades.clone(); }
    @SuppressWarnings("unchecked")
    public UpgradeBase setEquippedUpgrades(ArrayList<EquippedUpgrade> v) { equippedUpgrades = (ArrayList<EquippedUpgrade>)v.clone(); return this;}

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
