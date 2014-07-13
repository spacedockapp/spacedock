
package com.funnyhatsoftware.spacedock.data;

public class Maneuver extends ManeuverBase {

    public String getAsString() {
        StringBuilder sb = new StringBuilder();
        sb.append(mSpeed);
        sb.append(":");
        sb.append(mKind);
        sb.append(":");
        sb.append(mColor);
        return sb.toString();
    }

    int compareTo(Maneuver other) {
        return getAsString().compareTo(other.getAsString());
    }
}
