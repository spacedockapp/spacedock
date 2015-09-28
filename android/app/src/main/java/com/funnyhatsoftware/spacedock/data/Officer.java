package com.funnyhatsoftware.spacedock.data;

public class Officer extends OfficerBase {
    @Override
    public int calculateCostForShip(EquippedShip equippedShip, EquippedUpgrade equippedUpgrade) {
        if (isPlaceholder()) {
            return 0;
        }
        return 3;
    }
}
