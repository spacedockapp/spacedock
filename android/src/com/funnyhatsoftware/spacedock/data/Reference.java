package com.funnyhatsoftware.spacedock.data;

import java.util.Comparator;

public class Reference extends ReferenceBase {
    static class ReferenceComparator implements Comparator<Reference> {
        @Override
        public int compare(Reference o1, Reference o2) {
            return o1.getTitle().compareTo(o2.getTitle());
        }
    }

}
