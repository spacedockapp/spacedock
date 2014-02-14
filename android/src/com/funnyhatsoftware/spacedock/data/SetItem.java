
package com.funnyhatsoftware.spacedock.data;

public class SetItem extends SetItemBase {
    public String anySetExternalId()
    {
        Set set = mSets.get(0);
        return set.getExternalId();
    }

    public boolean getUnique() { return false; }
    public String getFaction() { return null; }
    public String getTitle() { return null; }
    public int getCost() { return -1; }
    public String getAbility() { return null; }
    public String getExternalId() { return null; }
}
