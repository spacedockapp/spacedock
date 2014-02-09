
package com.funnyhatsoftware.spacedock.data;

public class Sideboard extends SideboardBase {

    public static Sideboard sideboard() {
        Sideboard sideboard = new Sideboard();
        sideboard.establishPlaceholders();
        return sideboard;
    }

    public int cost() {
        Resource r = Resource.sideboardResource();
        return r.getCost();
    }

    @Override
    public int getTalent() {
        return 1;
    }

    @Override
    public int getTech() {
        return 1;
    }

    @Override
    public int getWeapon() {
        return 1;
    }

    @Override
    public int getCrew() {
        return 1;
    }

    @Override
    public Explanation canAddUpgrade(Upgrade upgrade) {
        return Explanation.SUCCESS;
    }

    public int baseCost() {
        int cost = 0;
        for (EquippedUpgrade eu : mUpgrades) {
            cost += eu.getBaseCost();
        }
        return cost;
    }

    public String factionCode() {
        return "";
    }
}
