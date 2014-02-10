
package com.funnyhatsoftware.spacedock.data;

public class Flagship extends FlagshipBase {

    String getName()
    {
        if (mFaction.equals("Independent")) {
            return mTitle;
        }
        return mFaction;
    }

    String getPlainDescription() {
        return "Flagship: " + mTitle;
    }

    boolean compatibleWithShip(Ship targetShip)
    {
        if (mFaction.equals("Independent")) {
            return true;
        }

        return mFaction.equals(targetShip.getFaction());
    }
    
}
