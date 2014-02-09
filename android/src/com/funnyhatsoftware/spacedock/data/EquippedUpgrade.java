
package com.funnyhatsoftware.spacedock.data;

public class EquippedUpgrade extends EquippedUpgradeBase {

    public int calculateCost() {
        if (mOverridden) {
            return mOverriddenCost;
        }
        return mUpgrade.mCost;
    }
}
