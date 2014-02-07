// Generated code, any edits will be eventually lost.
package com.funnyhatsoftware.spacedock.data;

import java.util.Map;

public class CaptainBase extends Upgrade {
    int skill;
    public int getSkill() { return skill; }
    public CaptainBase setSkill(int v) { skill = v; return this;}
    int talent;
    public int getTalent() { return talent; }
    public CaptainBase setTalent(int v) { talent = v; return this;}

    public void update(Map<String,Object> data) {
        skill = DataUtils.intValue((String)data.get("Skill"));
        talent = DataUtils.intValue((String)data.get("Talent"));
    }

}
