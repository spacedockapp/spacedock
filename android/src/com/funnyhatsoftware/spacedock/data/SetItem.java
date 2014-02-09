
package com.funnyhatsoftware.spacedock.data;

public class SetItem extends SetItemBase {
    
    public String anySetExternalId()
    {
        Set set = mSets.get(0);
        return set.getExternalId();
    }
}
