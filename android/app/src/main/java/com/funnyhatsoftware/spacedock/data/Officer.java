package com.funnyhatsoftware.spacedock.data;

public class Officer extends OfficerBase {
    @Override
    public int calculateCostForShip(EquippedShip equippedShip, EquippedUpgrade equippedUpgrade) {
        return 3;
    }
}
