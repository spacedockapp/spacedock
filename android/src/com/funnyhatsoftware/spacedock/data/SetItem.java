
package com.funnyhatsoftware.spacedock.data;

import java.util.ArrayList;

public class SetItem extends SetItemBase {
    public String anySetExternalId() {
        Set set = mSets.get(0);
        return set.getExternalId();
    }

    public String getSetName() {
        ArrayList<Set> sets = getSets();
        if (sets.size() > 0) {
            Set set = sets.get(0);
            return set.getProductName();
        }
        return "";
    }

    public boolean getUnique() {
        return false;
    }

    public String getFaction() {
        return null;
    }

    public String getTitle() {
        return null;
    }

    public String getDescriptiveTitle() {
        return null;
    }

    public int getCost() {
        return -1;
    }

    public String getAbility() {
        return null;
    }

    public String getExternalId() {
        return null;
    }

    public boolean isPlaceholder() {
        return false;
    }

    public void addToSet(Set set) {
        mSets.add(set);
    }
}
