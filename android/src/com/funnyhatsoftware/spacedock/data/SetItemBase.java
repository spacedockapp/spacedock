// Generated code, any edits will be eventually lost.
package com.funnyhatsoftware.spacedock.data;

import java.util.ArrayList;
import java.util.Map;

public abstract class SetItemBase extends Base {
    String mAdditionalFaction;
    public String getAdditionalFaction() { return mAdditionalFaction; }
    public SetItemBase setAdditionalFaction(String v) { mAdditionalFaction = v; return this;}
    ArrayList<Set> mSets = new ArrayList<Set>();
    @SuppressWarnings("unchecked")
    public ArrayList<Set> getSets() { return (ArrayList<Set>)mSets.clone(); }
    @SuppressWarnings("unchecked")
    public SetItemBase setSets(ArrayList<Set> v) { mSets = (ArrayList<Set>)v.clone(); return this;}

    public void update(Map<String,Object> data) {
        mAdditionalFaction = DataUtils.stringValue((String)data.get("AdditionalFaction"), "");
    }

}
