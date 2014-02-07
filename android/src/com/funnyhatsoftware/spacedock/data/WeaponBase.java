// Generated code, any edits will be eventually lost.
package com.funnyhatsoftware.spacedock.data;

import java.util.Map;

public class WeaponBase extends Upgrade {
    int attack;
    public int getAttack() { return attack; }
    public WeaponBase setAttack(int v) { attack = v; return this;}
    String range;
    public String getRange() { return range; }
    public WeaponBase setRange(String v) { range = v; return this;}

    public void update(Map<String,Object> data) {
        super.update(data);
        attack = DataUtils.intValue((String)data.get("Attack"));
        range = DataUtils.stringValue((String)data.get("Range"));
    }

}
