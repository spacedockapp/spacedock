package com.funnyhatsoftware.spacedock.data;

import java.util.Map;

public class CaptainBase extends Upgrade {
    public int skill;
    public int talent;

    public void update(Map<String,Object> data) {
        skill = DataUtils.intValue((String)data.get("Skill"));
        talent = DataUtils.intValue((String)data.get("Talent"));
    }

}
