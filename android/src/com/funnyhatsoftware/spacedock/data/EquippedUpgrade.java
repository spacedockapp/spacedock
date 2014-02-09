
package com.funnyhatsoftware.spacedock.data;

public class EquippedUpgrade extends EquippedUpgradeBase {

    public int calculateCost() {
        if (mOverridden) {
            return mOverriddenCost;
        }
        return mUpgrade.mCost;
    }

    public int compareTo(EquippedUpgrade arg1) {
        return getUpgrade().compareTo(arg1.getUpgrade());
    }

    String getTitle() {
        return getUpgrade().getTitle();
    }

    String getFaction() {
        return getUpgrade().getFaction();
    }

    boolean isPlaceholder() {
        return getUpgrade().isPlaceholder();
    }

    String getPlainDescription() {
        return getUpgrade().getPlainDescription();
    }

    int getBaseCost() {

        if (mUpgrade.isPlaceholder()) {
            return 0;
        }

        return mUpgrade.getCost();
    }

    int getNonOverriddenCost() {
        EquippedShip equippedShip = getEquippedShip();
        return mUpgrade.calculateCostForShip(equippedShip);
    }

    int getCost() {
        if (mOverridden) {
            return mOverriddenCost;
        }

        return getNonOverriddenCost();
    }

    int getRawCost() {
        return mUpgrade.getCost();
    }

}
