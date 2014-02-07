package com.funnyhatsoftware.spacedock.data;

import java.util.ArrayList;
import java.util.Map;

public class EquippedShipBase {
    public Flagship flagship;
    public Ship ship;
    public Squad squad;
    public ArrayList<EquippedUpgrade> upgrades = new ArrayList<EquippedUpgrade>();

    public void update(Map<String,Object> data) {
    }

}
