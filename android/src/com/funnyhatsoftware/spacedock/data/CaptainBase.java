// Generated code, any edits will be eventually lost.
package com.funnyhatsoftware.spacedock.data;

import java.util.Map;

public class CaptainBase extends Upgrade {
    int mSkill;
    public int getSkill() { return mSkill; }
    public CaptainBase setSkill(int v) { mSkill = v; return this;}
    int mTalent;
    public int getTalent() { return mTalent; }
    public CaptainBase setTalent(int v) { mTalent = v; return this;}

    public void update(Map<String,Object> data) {
        super.update(data);
        mSkill = DataUtils.intValue((String)data.get("Skill"), 0);
        mTalent = DataUtils.intValue((String)data.get("Talent"), 0);
    }

}
