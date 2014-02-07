package com.funnyhatsoftware.spacedock.data;

import java.util.Map;

public class WeaponBase extends Upgrade {
    public int attack;
    public String range;

    public void update(Map<String,Object> data) {
        attack = DataUtils.intValue((String)data.get("Attack"));
        range = DataUtils.stringValue((String)data.get("Range"));
    }

}
