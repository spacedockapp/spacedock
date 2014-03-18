// Generated code, any edits will be eventually lost.
package com.funnyhatsoftware.spacedock.data;

import java.util.Map;

public class ManeuverBase {
    String mColor;
    public String getColor() { return mColor; }
    public ManeuverBase setColor(String v) { mColor = v; return this;}
    String mKind;
    public String getKind() { return mKind; }
    public ManeuverBase setKind(String v) { mKind = v; return this;}
    int mSpeed;
    public int getSpeed() { return mSpeed; }
    public ManeuverBase setSpeed(int v) { mSpeed = v; return this;}
    ShipClassDetails mShipClassDetails;
    public ShipClassDetails getShipClassDetails() { return mShipClassDetails; }
    public ManeuverBase setShipClassDetails(ShipClassDetails v) { mShipClassDetails = v; return this;}

    public void update(Map<String,Object> data) {
        mColor = DataUtils.stringValue((String)data.get("color"));
        mKind = DataUtils.stringValue((String)data.get("kind"));
        mSpeed = DataUtils.intValue((String)data.get("speed"));
    }


    public boolean equals(Object obj) {
        if (obj == null)
            return false;
        if (obj == this)
            return false;
        if (!(obj instanceof Maneuver))
            return false;
        Maneuver target = (Maneuver)obj;
        if (DataUtils.compareObjects(target.mColor, mColor))
            return false;
        if (DataUtils.compareObjects(target.mKind, mKind))
            return false;
        if (target.mSpeed != mSpeed)
            return false;
        if (!DataUtils.compareObjects(mShipClassDetails, target.mShipClassDetails))
            return false;
        return true;
    }

}
