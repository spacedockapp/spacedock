// Generated code, any edits will be eventually lost.
package com.funnyhatsoftware.spacedock.data;

import java.util.Map;

public class AdmiralBase extends Captain {
    String mAdmiralAbility;
    public String getAdmiralAbility() { return mAdmiralAbility; }
    public AdmiralBase setAdmiralAbility(String v) { mAdmiralAbility = v; return this;}
    int mAdmiralCost;
    public int getAdmiralCost() { return mAdmiralCost; }
    public AdmiralBase setAdmiralCost(int v) { mAdmiralCost = v; return this;}
    int mAdmiralTalent;
    public int getAdmiralTalent() { return mAdmiralTalent; }
    public AdmiralBase setAdmiralTalent(int v) { mAdmiralTalent = v; return this;}
    int mSkillModifier;
    public int getSkillModifier() { return mSkillModifier; }
    public AdmiralBase setSkillModifier(int v) { mSkillModifier = v; return this;}

    public void update(Map<String,Object> data) {
        super.update(data);
        mAdmiralAbility = DataUtils.stringValue((String)data.get("AdmiralAbility"), "");
        mAdmiralCost = DataUtils.intValue((String)data.get("AdmiralCost"), 0);
        mAdmiralTalent = DataUtils.intValue((String)data.get("AdmiralTalent"), 0);
        mSkillModifier = DataUtils.intValue((String)data.get("SkillModifier"), 0);
    }

}
