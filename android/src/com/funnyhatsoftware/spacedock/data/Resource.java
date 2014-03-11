
package com.funnyhatsoftware.spacedock.data;

import java.util.Comparator;

public class Resource extends ResourceBase {

    public static final String kSideboardExternalId = "4003";
    public static final String kFlagshipExternalId = "4004";

    static class ResourceComparator implements Comparator<Resource> {
        @Override
        public int compare(Resource o1, Resource o2) {
            int titleCompare = o1.getTitle().compareTo(o2.getTitle());
            if (titleCompare == 0) {
                return DataUtils.compareInt(o2.getCost(), o1.getCost());
            }
            return titleCompare;
        }
    }

    public static Resource resourceForId(String externalId) {
        return Universe.getUniverse().getResource(externalId);
    }

    public static Resource sideboardResource() {
        return Resource.resourceForId(kSideboardExternalId);
    }

    public static Resource flagshipResource() {
        return resourceForId(kFlagshipExternalId);
    }

    public String getPlainDescription() {
        return mTitle;
    }

    public boolean getIsSideboard() {
        return mExternalId.equals(kSideboardExternalId);
    }

    public boolean getIsFlagship() {
        return mExternalId.equals(kFlagshipExternalId);
    }
}
