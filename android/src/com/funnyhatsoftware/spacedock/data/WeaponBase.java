// Generated code, any edits will be eventually lost.
package com.funnyhatsoftware.spacedock.data;

import java.util.Map;

public class WeaponBase extends Upgrade {
    int mAttack;
    public int getAttack() { return mAttack; }
    public WeaponBase setAttack(int v) { mAttack = v; return this;}
    String mRange;
    public String getRange() { return mRange; }
    public WeaponBase setRange(String v) { mRange = v; return this;}

    public void update(Map<String,Object> data) {
        super.update(data);
        mAttack = DataUtils.intValue((String)data.get("Attack"));
        mRange = DataUtils.stringValue((String)data.get("Range"));
    }


    public boolean equals(Object obj) {
        if (obj == null)
            return false;
        if (obj == this)
            return false;
        if (!(obj instanceof Weapon))
            return false;
        Weapon target = (Weapon)obj;
        if (target.mAttack != mAttack)
            return false;
        if (DataUtils.compareObjects(target.mRange, mRange))
            return false;
        return true;
    }

}
