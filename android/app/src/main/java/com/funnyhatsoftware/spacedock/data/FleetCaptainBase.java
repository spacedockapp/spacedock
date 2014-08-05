// Generated code, any edits will be eventually lost.
package com.funnyhatsoftware.spacedock.data;

import java.util.Map;

public class FleetCaptainBase extends Upgrade {
    int mCaptainSkillBonus;
    public int getCaptainSkillBonus() { return mCaptainSkillBonus; }
    public FleetCaptainBase setCaptainSkillBonus(int v) { mCaptainSkillBonus = v; return this;}
    int mCrewAdd;
    public int getCrewAdd() { return mCrewAdd; }
    public FleetCaptainBase setCrewAdd(int v) { mCrewAdd = v; return this;}
    int mTalentAdd;
    public int getTalentAdd() { return mTalentAdd; }
    public FleetCaptainBase setTalentAdd(int v) { mTalentAdd = v; return this;}
    int mTechAdd;
    public int getTechAdd() { return mTechAdd; }
    public FleetCaptainBase setTechAdd(int v) { mTechAdd = v; return this;}
    int mWeaponAdd;
    public int getWeaponAdd() { return mWeaponAdd; }
    public FleetCaptainBase setWeaponAdd(int v) { mWeaponAdd = v; return this;}

    public void update(Map<String,Object> data) {
        super.update(data);
        mCaptainSkillBonus = DataUtils.intValue((String)data.get("CaptainSkillBonus"), 0);
        mCrewAdd = DataUtils.intValue((String)data.get("CrewAdd"), 0);
        mTalentAdd = DataUtils.intValue((String)data.get("TalentAdd"), 0);
        mTechAdd = DataUtils.intValue((String)data.get("TechAdd"), 0);
        mWeaponAdd = DataUtils.intValue((String)data.get("WeaponAdd"), 0);
    }

}
