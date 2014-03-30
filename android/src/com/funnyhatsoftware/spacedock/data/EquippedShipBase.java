// Generated code, any edits will be eventually lost.
package com.funnyhatsoftware.spacedock.data;

import java.util.ArrayList;
import java.util.Map;

public class EquippedShipBase extends Base {
    Flagship mFlagship;
    public Flagship getFlagship() { return mFlagship; }
    public EquippedShipBase setFlagship(Flagship v) { mFlagship = v; return this;}
    Ship mShip;
    public Ship getShip() { return mShip; }
    public EquippedShipBase setShip(Ship v) { mShip = v; return this;}
    Squad mSquad;
    public Squad getSquad() { return mSquad; }
    public EquippedShipBase setSquad(Squad v) { mSquad = v; return this;}
    ArrayList<EquippedUpgrade> mUpgrades = new ArrayList<EquippedUpgrade>();
    @SuppressWarnings("unchecked")
    public ArrayList<EquippedUpgrade> getUpgrades() { return (ArrayList<EquippedUpgrade>)mUpgrades.clone(); }
    @SuppressWarnings("unchecked")
    public EquippedShipBase setUpgrades(ArrayList<EquippedUpgrade> v) { mUpgrades = (ArrayList<EquippedUpgrade>)v.clone(); return this;}

    public void update(Map<String,Object> data) {
    }

}
