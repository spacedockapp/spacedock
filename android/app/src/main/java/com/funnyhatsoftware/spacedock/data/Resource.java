
package com.funnyhatsoftware.spacedock.data;

import java.util.Comparator;

public class Resource extends ResourceBase {

    public static final String kSideboardExternalId = "4003";
    public static final String kFlagshipExternalId = "4004";
    public static final String kFleetCaptainExternalId = "fleet_captain_collectiveop2";
    public static final String kHidekiExternalId = "hideki_class_attack_squadron_op5participation";
    public static final String kFedFighterExternalId = "federation_attack_fighters_op6participation";

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

    public boolean isFleetCaptain() { return mExternalId.equals(kFleetCaptainExternalId);}

    public boolean getIsFighterSquadron() {
        return mExternalId.equals(kHidekiExternalId) || mExternalId.equals(kFedFighterExternalId);
    }

    public Ship associatedShip() {
        Ship associated = null;
        if (getIsFighterSquadron()) {
            String externalId = getExternalId();
            if (externalId != null) {
                Universe universe = Universe.getUniverse();
                if (externalId.equals(kFedFighterExternalId)) {
                    associated = universe.getShip(Constants.FED_FIGHTERS);
                } else if (externalId.equals(kHidekiExternalId)) {
                    associated = universe.getShip(Constants.HIDEKIS);
                }
            }
        }
        return associated;
    }

    /**
     * Returns true if the Resource is built into Squad as either a ship, or an upgrade
     * (TODO: better name)
     *
     * Resources that return true do not need to be cost counted separately
     */
    public boolean equippedIntoSquad(Squad squad) {

        return getIsFlagship() || isFleetCaptain() || getIsSideboard()
                || getIsFighterSquadron();
    }
}
