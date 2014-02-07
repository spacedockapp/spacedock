// Generated code, any edits will be eventually lost.
package com.funnyhatsoftware.spacedock.data;

import java.util.ArrayList;
import java.util.Map;

public class EquippedShipBase {
    Flagship flagship;
    public Flagship getFlagship() { return flagship; }
    public EquippedShipBase setFlagship(Flagship v) { flagship = v; return this;}
    Ship ship;
    public Ship getShip() { return ship; }
    public EquippedShipBase setShip(Ship v) { ship = v; return this;}
    Squad squad;
    public Squad getSquad() { return squad; }
    public EquippedShipBase setSquad(Squad v) { squad = v; return this;}
    ArrayList<EquippedUpgrade> upgrades = new ArrayList<EquippedUpgrade>();
    @SuppressWarnings("unchecked")
    public ArrayList<EquippedUpgrade> getUpgrades() { return (ArrayList<EquippedUpgrade>)upgrades.clone(); }
    @SuppressWarnings("unchecked")
    public EquippedShipBase setUpgrades(ArrayList<EquippedUpgrade> v) { upgrades = (ArrayList<EquippedUpgrade>)v.clone(); return this;}

    public void update(Map<String,Object> data) {
    }

}
