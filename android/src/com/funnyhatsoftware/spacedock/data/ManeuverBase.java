// Generated code, any edits will be eventually lost.
package com.funnyhatsoftware.spacedock.data;

import java.util.Map;

public class ManeuverBase extends Base {
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
        mSpeed = DataUtils.intValue((String)data.get("speed"), 1);
    }

}
