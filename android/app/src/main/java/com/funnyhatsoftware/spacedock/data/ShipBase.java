// Generated code, any edits will be eventually lost.
package com.funnyhatsoftware.spacedock.data;

import android.util.Log;

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
    int mBorg;
    public int getBorg() { return mBorg; }
    public ShipBase setBorg(int v) { mBorg = v; return this;}
    int mCaptainLimit;
    public int getCaptainLimit() { return mCaptainLimit; }
    public ShipBase setCaptainLimit(int v) { mCaptainLimit = v; return this;}
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
    boolean mHas360Arc;
    public boolean getHas360Arc() { return mHas360Arc; }
    public ShipBase setHas360Arc(boolean v) { mHas360Arc = v; return this;}
    int mHull;
    public int getHull() { return mHull; }
    public ShipBase setHull(int v) { mHull = v; return this;}
    int mRegenerate;
    public int getRegenerate() { return mRegenerate; }
    public ShipBase setRegenerate(int v) { mRegenerate = v; return this;}
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
    int mSquadron;
    public int getSquadron() { return mSquadron; }
    public ShipBase setSquadron(int v) { mSquadron = v; return this;}
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
        mAbility = DataUtils.stringValue((String) data.get("Ability"), "");
        mAgility = DataUtils.intValue((String)data.get("Agility"), 0);
        mAttack = DataUtils.intValue((String)data.get("Attack"), 0);
        mBattleStations = DataUtils.intValue((String)data.get("Battlestations"), 0);
        mBorg = DataUtils.intValue((String)data.get("Borg"), 0);
        mCaptainLimit = DataUtils.intValue((String)data.get("CaptainLimit"), 1);
        mCloak = DataUtils.intValue((String)data.get("Cloak"), 0);
        mCost = DataUtils.intValue((String)data.get("Cost"), 0);
        mCrew = DataUtils.intValue((String)data.get("Crew"), 0);
        mEvasiveManeuvers = DataUtils.intValue((String) data.get("EvasiveManeuvers"), 0);
        mExternalId = DataUtils.stringValue((String)data.get("Id"), "");
        mFaction = DataUtils.stringValue((String) data.get("Faction"), "Independent");
        mHas360Arc = DataUtils.booleanValue((String) data.get("Has360Arc"));
        mHull = DataUtils.intValue((String)data.get("Hull"), 1);
        mRegenerate = DataUtils.intValue((String)data.get("Regenerate"), 0);
        mScan = DataUtils.intValue((String)data.get("Scan"), 0);
        mSensorEcho = DataUtils.intValue((String)data.get("SensorEcho"), 0);
        mShield = DataUtils.intValue((String) data.get("Shield"), 0);
        mShipClass = DataUtils.stringValue((String) data.get("ShipClass"), "");
        mSquadron = DataUtils.intValue((String)data.get("SquadronUpgrade"), 0);
        mTargetLock = DataUtils.intValue((String)data.get("TargetLock"), 0);
        mTech = DataUtils.intValue((String) data.get("Tech"), 0);
        mTitle = DataUtils.stringValue((String) data.get("Title"), "Untitled");
        mUnique = DataUtils.booleanValue((String) data.get("Unique"));
        mWeapon = DataUtils.intValue((String)data.get("Weapon"), 0);
    }

}
