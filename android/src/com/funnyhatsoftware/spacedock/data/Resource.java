
package com.funnyhatsoftware.spacedock.data;

public class Resource extends ResourceBase {

    public static final String kSideboardExternalId = "4003";
    public static final String kFlagshipExternalId = "4004";

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
