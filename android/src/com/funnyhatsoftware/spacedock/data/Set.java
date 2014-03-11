
package com.funnyhatsoftware.spacedock.data;

import java.util.ArrayList;

public class Set extends SetBase {

    public static Set setForId(String setId) {
        return Universe.getUniverse().getSet(setId);
    }

    public static ArrayList<Set> allSets() {
        return Universe.getUniverse().getAllSets();
    }

    public static ArrayList<Set> includedSets() {
        return Universe.getUniverse().includedSets();
    }

    public void addToSet(SetItem item) {
        ArrayList<Set> otherSets = item.getSets();
        for (Set otherSet : otherSets) {
            otherSet.remove(item);
        }
        mItems.add(item);
        item.addToSet(this);
    }

    public void remove(SetItem item) {
        mItems.remove(item);
    }
}
