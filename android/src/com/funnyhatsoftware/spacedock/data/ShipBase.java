// Generated code, any edits will be eventually lost.
package com.funnyhatsoftware.spacedock.data;

import java.util.ArrayList;
import java.util.Map;

public class ShipBase extends SetItem {
    String mAbility;
    public String getAbility() { return mAbility; }
    public ShipBase setAbility(String v) { mAbility = v; return this;}
    int mAgility;
    public int getAgility() { return mAgility; }
    public ShipBase setAgility(int v) { mAgility = v; return this;}
    int mAttack;
    public int getAttack() { return mAttack; }
    public ShipBase setAttack(int v) { mAttack = v; return this;}
    int mBattleStations;
    public int getBattleStations() { return mBattleStations; }
    public ShipBase setBattleStations(int v) { mBattleStations = v; return this;}
    int mCloak;
    public int getCloak() { return mCloak; }
    public ShipBase setCloak(int v) { mCloak = v; return this;}
    int mCost;
    public int getCost() { return mCost; }
    public ShipBase setCost(int v) { mCost = v; return this;}
    int mCrew;
    public int getCrew() { return mCrew; }
    public ShipBase setCrew(int v) { mCrew = v; return this;}
    int mEvasiveManeuvers;
    public int getEvasiveManeuvers() { return mEvasiveManeuvers; }
    public ShipBase setEvasiveManeuvers(int v) { mEvasiveManeuvers = v; return this;}
    String mExternalId;
    public String getExternalId() { return mExternalId; }
    public ShipBase setExternalId(String v) { mExternalId = v; return this;}
    String mFaction;
    public String getFaction() { return mFaction; }
    public ShipBase setFaction(String v) { mFaction = v; return this;}
    int mHull;
    public int getHull() { return mHull; }
    public ShipBase setHull(int v) { mHull = v; return this;}
    int mScan;
    public int getScan() { return mScan; }
    public ShipBase setScan(int v) { mScan = v; return this;}
    int mSensorEcho;
    public int getSensorEcho() { return mSensorEcho; }
    public ShipBase setSensorEcho(int v) { mSensorEcho = v; return this;}
    int mShield;
    public int getShield() { return mShield; }
    public ShipBase setShield(int v) { mShield = v; return this;}
    String mShipClass;
    public String getShipClass() { return mShipClass; }
    public ShipBase setShipClass(String v) { mShipClass = v; return this;}
    int mTargetLock;
    public int getTargetLock() { return mTargetLock; }
    public ShipBase setTargetLock(int v) { mTargetLock = v; return this;}
    int mTech;
    public int getTech() { return mTech; }
    public ShipBase setTech(int v) { mTech = v; return this;}
    String mTitle;
    public String getTitle() { return mTitle; }
    public ShipBase setTitle(String v) { mTitle = v; return this;}
    boolean mUnique;
    public boolean getUnique() { return mUnique; }
    public ShipBase setUnique(boolean v) { mUnique = v; return this;}
    int mWeapon;
    public int getWeapon() { return mWeapon; }
    public ShipBase setWeapon(int v) { mWeapon = v; return this;}
    ShipClassDetails mShipClassDetails;
    public ShipClassDetails getShipClassDetails() { return mShipClassDetails; }
    public ShipBase setShipClassDetails(ShipClassDetails v) { mShipClassDetails = v; return this;}
    ArrayList<EquippedShip> mEquippedShips = new ArrayList<EquippedShip>();
    @SuppressWarnings("unchecked")
    public ArrayList<EquippedShip> getEquippedShips() { return (ArrayList<EquippedShip>)mEquippedShips.clone(); }
    @SuppressWarnings("unchecked")
    public ShipBase setEquippedShips(ArrayList<EquippedShip> v) { mEquippedShips = (ArrayList<EquippedShip>)v.clone(); return this;}

    public void update(Map<String,Object> data) {
        super.update(data);
        mAbility = DataUtils.stringValue((String)data.get("Ability"));
        mAgility = DataUtils.intValue((String)data.get("Agility"));
        mAttack = DataUtils.intValue((String)data.get("Attack"));
        mBattleStations = DataUtils.intValue((String)data.get("Battlestations"));
        mCloak = DataUtils.intValue((String)data.get("Cloak"));
        mCost = DataUtils.intValue((String)data.get("Cost"));
        mCrew = DataUtils.intValue((String)data.get("Crew"));
        mEvasiveManeuvers = DataUtils.intValue((String)data.get("EvasiveManeuvers"));
        mExternalId = DataUtils.stringValue((String)data.get("Id"));
        mFaction = DataUtils.stringValue((String)data.get("Faction"));
        mHull = DataUtils.intValue((String)data.get("Hull"));
        mScan = DataUtils.intValue((String)data.get("Scan"));
        mSensorEcho = DataUtils.intValue((String)data.get("SensorEcho"));
        mShield = DataUtils.intValue((String)data.get("Shield"));
        mShipClass = DataUtils.stringValue((String)data.get("ShipClass"));
        mTargetLock = DataUtils.intValue((String)data.get("TargetLock"));
        mTech = DataUtils.intValue((String)data.get("Tech"));
        mTitle = DataUtils.stringValue((String)data.get("Title"));
        mUnique = DataUtils.booleanValue((String)data.get("Unique"));
        mWeapon = DataUtils.intValue((String)data.get("Weapon"));
    }


    public boolean equals(Object obj) {
        if (obj == null)
            return false;
        if (obj == this)
            return false;
        if (!(obj instanceof Ship))
            return false;
        Ship target = (Ship)obj;
        if (DataUtils.compareObjects(target.mAbility, mAbility))
            return false;
        if (target.mAgility != mAgility)
            return false;
        if (target.mAttack != mAttack)
            return false;
        if (target.mBattleStations != mBattleStations)
            return false;
        if (target.mCloak != mCloak)
            return false;
        if (target.mCost != mCost)
            return false;
        if (target.mCrew != mCrew)
            return false;
        if (target.mEvasiveManeuvers != mEvasiveManeuvers)
            return false;
        if (DataUtils.compareObjects(target.mExternalId, mExternalId))
            return false;
        if (DataUtils.compareObjects(target.mFaction, mFaction))
            return false;
        if (target.mHull != mHull)
            return false;
        if (target.mScan != mScan)
            return false;
        if (target.mSensorEcho != mSensorEcho)
            return false;
        if (target.mShield != mShield)
            return false;
        if (DataUtils.compareObjects(target.mShipClass, mShipClass))
            return false;
        if (target.mTargetLock != mTargetLock)
            return false;
        if (target.mTech != mTech)
            return false;
        if (DataUtils.compareObjects(target.mTitle, mTitle))
            return false;
        if (target.mUnique != mUnique)
            return false;
        if (target.mWeapon != mWeapon)
            return false;
        if (!DataUtils.compareObjects(mShipClassDetails, target.mShipClassDetails))
            return false;
        if (!DataUtils.compareObjects(mEquippedShips, target.mEquippedShips))
            return false;
        return true;
    }

}
