// Generated code, any edits will be eventually lost.
package com.funnyhatsoftware.spacedock.data;

import java.util.Map;

public class ReferenceBase extends SetItem {
    String mAbility;
    public String getAbility() { return mAbility; }
    public ReferenceBase setAbility(String v) { mAbility = v; return this;}
    String mExternalId;
    public String getExternalId() { return mExternalId; }
    public ReferenceBase setExternalId(String v) { mExternalId = v; return this;}
    String mTitle;
    public String getTitle() { return mTitle; }
    public ReferenceBase setTitle(String v) { mTitle = v; return this;}
    String mType;
    public String getType() { return mType; }
    public ReferenceBase setType(String v) { mType = v; return this;}

    public void update(Map<String,Object> data) {
        super.update(data);
        mAbility = DataUtils.stringValue((String)data.get("Ability"), "");
        mExternalId = DataUtils.stringValue((String)data.get("Id"), "");
        mTitle = DataUtils.stringValue((String)data.get("Title"), "");
        mType = DataUtils.stringValue((String)data.get("Type"), "");
    }

}
