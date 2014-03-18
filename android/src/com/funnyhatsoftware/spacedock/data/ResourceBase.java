// Generated code, any edits will be eventually lost.
package com.funnyhatsoftware.spacedock.data;

import java.util.ArrayList;
import java.util.Map;

public class ResourceBase extends SetItem {
    String mAbility;
    public String getAbility() { return mAbility; }
    public ResourceBase setAbility(String v) { mAbility = v; return this;}
    int mCost;
    public int getCost() { return mCost; }
    public ResourceBase setCost(int v) { mCost = v; return this;}
    String mExternalId;
    public String getExternalId() { return mExternalId; }
    public ResourceBase setExternalId(String v) { mExternalId = v; return this;}
    String mSpecial;
    public String getSpecial() { return mSpecial; }
    public ResourceBase setSpecial(String v) { mSpecial = v; return this;}
    String mTitle;
    public String getTitle() { return mTitle; }
    public ResourceBase setTitle(String v) { mTitle = v; return this;}
    String mType;
    public String getType() { return mType; }
    public ResourceBase setType(String v) { mType = v; return this;}
    boolean mUnique;
    public boolean getUnique() { return mUnique; }
    public ResourceBase setUnique(boolean v) { mUnique = v; return this;}
    ArrayList<Squad> mSquad = new ArrayList<Squad>();
    @SuppressWarnings("unchecked")
    public ArrayList<Squad> getSquad() { return (ArrayList<Squad>)mSquad.clone(); }
    @SuppressWarnings("unchecked")
    public ResourceBase setSquad(ArrayList<Squad> v) { mSquad = (ArrayList<Squad>)v.clone(); return this;}

    public void update(Map<String,Object> data) {
        super.update(data);
        mAbility = DataUtils.stringValue((String)data.get("Ability"));
        mCost = DataUtils.intValue((String)data.get("Cost"));
        mExternalId = DataUtils.stringValue((String)data.get("Id"));
        mSpecial = DataUtils.stringValue((String)data.get("Special"));
        mTitle = DataUtils.stringValue((String)data.get("Title"));
        mType = DataUtils.stringValue((String)data.get("Type"));
        mUnique = DataUtils.booleanValue((String)data.get("Unique"));
    }


    public boolean equals(Object obj) {
        if (obj == null)
            return false;
        if (obj == this)
            return false;
        if (!(obj instanceof Resource))
            return false;
        Resource target = (Resource)obj;
        if (DataUtils.compareObjects(target.mAbility, mAbility))
            return false;
        if (target.mCost != mCost)
            return false;
        if (DataUtils.compareObjects(target.mExternalId, mExternalId))
            return false;
        if (DataUtils.compareObjects(target.mSpecial, mSpecial))
            return false;
        if (DataUtils.compareObjects(target.mTitle, mTitle))
            return false;
        if (DataUtils.compareObjects(target.mType, mType))
            return false;
        if (target.mUnique != mUnique)
            return false;
        if (!DataUtils.compareObjects(mSquad, target.mSquad))
            return false;
        return true;
    }

}
