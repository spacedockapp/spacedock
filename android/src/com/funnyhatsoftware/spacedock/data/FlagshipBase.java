// Generated code, any edits will be eventually lost.
package com.funnyhatsoftware.spacedock.data;

import java.util.ArrayList;
import java.util.Map;

public class FlagshipBase extends SetItem {
    String mAbility;
    public String getAbility() { return mAbility; }
    public FlagshipBase setAbility(String v) { mAbility = v; return this;}
    int mAgility;
    public int getAgility() { return mAgility; }
    public FlagshipBase setAgility(int v) { mAgility = v; return this;}
    int mAttack;
    public int getAttack() { return mAttack; }
    public FlagshipBase setAttack(int v) { mAttack = v; return this;}
    int mBattleStations;
    public int getBattleStations() { return mBattleStations; }
    public FlagshipBase setBattleStations(int v) { mBattleStations = v; return this;}
    int mCloak;
    public int getCloak() { return mCloak; }
    public FlagshipBase setCloak(int v) { mCloak = v; return this;}
    int mCost;
    public int getCost() { return mCost; }
    public FlagshipBase setCost(int v) { mCost = v; return this;}
    int mCrew;
    public int getCrew() { return mCrew; }
    public FlagshipBase setCrew(int v) { mCrew = v; return this;}
    int mEvasiveManeuvers;
    public int getEvasiveManeuvers() { return mEvasiveManeuvers; }
    public FlagshipBase setEvasiveManeuvers(int v) { mEvasiveManeuvers = v; return this;}
    String mExternalId;
    public String getExternalId() { return mExternalId; }
    public FlagshipBase setExternalId(String v) { mExternalId = v; return this;}
    String mFaction;
    public String getFaction() { return mFaction; }
    public FlagshipBase setFaction(String v) { mFaction = v; return this;}
    int mHull;
    public int getHull() { return mHull; }
    public FlagshipBase setHull(int v) { mHull = v; return this;}
    int mScan;
    public int getScan() { return mScan; }
    public FlagshipBase setScan(int v) { mScan = v; return this;}
    int mSensorEcho;
    public int getSensorEcho() { return mSensorEcho; }
    public FlagshipBase setSensorEcho(int v) { mSensorEcho = v; return this;}
    int mShield;
    public int getShield() { return mShield; }
    public FlagshipBase setShield(int v) { mShield = v; return this;}
    int mTalent;
    public int getTalent() { return mTalent; }
    public FlagshipBase setTalent(int v) { mTalent = v; return this;}
    int mTargetLock;
    public int getTargetLock() { return mTargetLock; }
    public FlagshipBase setTargetLock(int v) { mTargetLock = v; return this;}
    int mTech;
    public int getTech() { return mTech; }
    public FlagshipBase setTech(int v) { mTech = v; return this;}
    String mTitle;
    public String getTitle() { return mTitle; }
    public FlagshipBase setTitle(String v) { mTitle = v; return this;}
    int mWeapon;
    public int getWeapon() { return mWeapon; }
    public FlagshipBase setWeapon(int v) { mWeapon = v; return this;}
    ArrayList<EquippedShip> mShips = new ArrayList<EquippedShip>();
    @SuppressWarnings("unchecked")
    public ArrayList<EquippedShip> getShips() { return (ArrayList<EquippedShip>)mShips.clone(); }
    @SuppressWarnings("unchecked")
    public FlagshipBase setShips(ArrayList<EquippedShip> v) { mShips = (ArrayList<EquippedShip>)v.clone(); return this;}

    public void update(Map<String,Object> data) {
        super.update(data);
        mAbility = DataUtils.stringValue((String)data.get("Ability"));
        mAgility = DataUtils.intValue((String)data.get("Agility"), 0);
        mAttack = DataUtils.intValue((String)data.get("Attack"), 0);
        mBattleStations = DataUtils.intValue((String)data.get("Battlestations"), 0);
        mCloak = DataUtils.intValue((String)data.get("Cloak"), 0);
        mCost = DataUtils.intValue((String)data.get("Cost"), 0);
        mCrew = DataUtils.intValue((String)data.get("Crew"), 0);
        mEvasiveManeuvers = DataUtils.intValue((String)data.get("EvasiveManeuvers"), 0);
        mExternalId = DataUtils.stringValue((String)data.get("Id"));
        mFaction = DataUtils.stringValue((String)data.get("Faction"));
        mHull = DataUtils.intValue((String)data.get("Hull"), 0);
        mScan = DataUtils.intValue((String)data.get("Scan"), 0);
        mSensorEcho = DataUtils.intValue((String)data.get("SensorEcho"), 0);
        mShield = DataUtils.intValue((String)data.get("Shield"), 0);
        mTalent = DataUtils.intValue((String)data.get("Talent"), 0);
        mTargetLock = DataUtils.intValue((String)data.get("TargetLock"), 0);
        mTech = DataUtils.intValue((String)data.get("Tech"), 0);
        mTitle = DataUtils.stringValue((String)data.get("Title"));
        mWeapon = DataUtils.intValue((String)data.get("Weapon"), 0);
    }

}
