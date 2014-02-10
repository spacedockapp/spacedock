
package com.funnyhatsoftware.spacedock.data;

public class SetItem extends SetItemBase {
    public String anySetExternalId()
    {
        Set set = mSets.get(0);
        return set.getExternalId();
    }

    public String getTitle() { return null; }
    public int getCost() { return -1; }
    public String getExternalId() { return null; }
}
