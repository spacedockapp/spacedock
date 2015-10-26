
package com.funnyhatsoftware.spacedock.data;

import java.text.DateFormat;
import java.util.ArrayList;
import java.util.Comparator;

public class Set extends SetBase {
    public static class SetComparator implements Comparator<Set> {
        @Override
        public int compare(Set o1, Set o2) {
            int v = o1.getReleaseDate().compareTo(o2.getReleaseDate());
            if (v == 0) {
                v = o1.getProductName().compareToIgnoreCase(o2.getProductName());
            }
            return v;
        }
    }

    public static Set setForId(String setId) {
        return Universe.getUniverse().getSet(setId);
    }

    public static ArrayList<Set> allSets() {
        return Universe.getUniverse().getAllSets();
    }

    public void addToSet(SetItem item) {
        mItems.add(item);
        item.addToSet(this);
    }

    public void remove(SetItem item) {
        mItems.remove(item);
    }

    public String getSection() {
        String dateString = DateFormat.getDateInstance().format(getReleaseDate());
        String section = dateString + " - " + getWave();

        return section;
    }
}
